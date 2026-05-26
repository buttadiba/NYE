#include "esp_camera.h"
#include "Arduino.h"
#include "FS.h"
#include "SD_MMC.h"
#include <Adafruit_NeoPixel.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h> 

// ==========================================
// CONFIGURATION DU RÉSEAU WIFI
// ==========================================
const char* ssid = "....adiba";
const char* password = "bestgirl2";

// ==========================================
// CONFIGURATION DES BROCHES
// ==========================================
#define PIR_PIN 13       
#define FLAME_PIN 12     
#define BUZZER_PIN 15    
#define LED_PIN 4        
#define NUM_LEDS 300

Adafruit_NeoPixel pixels(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

// ==========================================
// VARIABLES DE L'ALARME ET DE L'APP
// ==========================================
bool systemEnabled = true; 
bool alarmOn = false;
String alarmType = ""; 
unsigned long alarmStartTime = 0;
const unsigned long ALARM_DURATION = 10000; 

int alarmFreq = 400;
int alarmStep = 20;
unsigned long lastLedToggle = 0;
bool ledState = false;

// ==========================================
// CONFIGURATION CAMÉRA AI THINKER
// ==========================================
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

WebServer server(80);

// Déclarations des fonctions
void connectWiFi();
void startupAnimation();
void setAllRed();
void clearAllLeds();
void alarmSound();
void captureAndSave();
void sendAlert(String type);

void connectWiFi() {
  WiFi.begin(ssid, password);
  Serial.print("Connexion WiFi...");
  unsigned long startAttempt = millis();
  
  while (WiFi.status() != WL_CONNECTED && millis() - startAttempt < 15000) {
    delay(500);
    Serial.print(".");
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nConnecté !");
    Serial.print("IP ESP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nÉchec WiFi : Mode local activé.");
  }
}

void sendAlert(String type) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http; 
  http.begin("http://10.155.45.239:5000/add-alert"); 
  http.setTimeout(2000); 
  http.addHeader("Content-Type", "application/json");
  
  String json = "{\"type\":\"" + type + "\", \"description\":\"Alerte ESP\"}";
  int code = http.POST(json);
  http.end();
}

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); 
  Serial.begin(115200);
  delay(500);

  pixels.begin();
  pixels.show();
  pixels.setBrightness(60); 

  connectWiFi(); 

  pinMode(PIR_PIN, INPUT_PULLDOWN);  
  pinMode(FLAME_PIN, INPUT_PULLUP);  
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // CONFIGURATION CAMÉRA
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.frame_size = FRAMESIZE_VGA;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("ERREUR CAMERA");
  }

  if (!SD_MMC.begin("/sdcard", true)) {
    Serial.println("ERREUR SD");
  }

  Serial.println("Calibration...");
  startupAnimation();
  Serial.println("Système prêt !");

  // ROUTES POUR L'APPLICATION
  server.on("/", []() {
    String statut = systemEnabled ? "ACTIVE" : "DESACTIVE";
    server.send(200, "text/html", "<h1>ESP32 ALARME</h1><p>Surveillance: " + statut + "</p>");
  });

  server.on("/api/on", []() {
    systemEnabled = true;

    //  faire un reset propre du système
    alarmOn = false;
    alarmType = "";
    noTone(BUZZER_PIN);
    digitalWrite(BUZZER_PIN, LOW);
    clearAllLeds();

    server.send(200, "application/json", "{\"status\":\"ON\"}");
  });
  server.on("/api/off", []() {
    systemEnabled = false;
    alarmOn = false;
    alarmType = "";
    noTone(BUZZER_PIN);
    digitalWrite(BUZZER_PIN, LOW);
    clearAllLeds();
    server.send(200, "application/json", "{\"status\":\"OFF\"}");
  });

  server.begin();
}

void loop() {
  server.handleClient();
  
  if (!systemEnabled) {
    delay(10);
    return; 
  }

  // ---- MODE SURVEILLANCE ----
  if (!alarmOn) {
    int flameReading = digitalRead(FLAME_PIN);
    int mvtReading = digitalRead(PIR_PIN);

    if (flameReading == LOW || mvtReading == HIGH) {
      delay(100); 
      
      if (digitalRead(FLAME_PIN) == LOW) { 
        Serial.println("!!! CONFIRMATION FEU !!!");
        alarmOn = true;
        alarmType = "feu";
        alarmStartTime = millis();
        alarmFreq = 800; 
        alarmStep = 35;
        setAllRed(); 
        sendAlert("feu");
        captureAndSave();
      } 
      else if (digitalRead(PIR_PIN) == HIGH) { 
        Serial.println("!!! CONFIRMATION MOUVEMENT !!!");
        alarmOn = true;
        alarmType = "mouvement";
        alarmStartTime = millis();
        alarmFreq = 400; 
        alarmStep = 15;
        setAllRed(); 
        sendAlert("mouvement");
        captureAndSave();
      }
    }
    
  } else {
    // ---- MODE ALARME EN COURS ----
    if (millis() - alarmStartTime >= ALARM_DURATION) {
      noTone(BUZZER_PIN);    
      digitalWrite(BUZZER_PIN, LOW);
      clearAllLeds();  
      alarmOn = false;       
      alarmType = "";
      delay(1500);           
      return;
    }

    alarmSound();

    // Gestion des rythmes de clignotement (toujours en Rouge)
    unsigned long toggleInterval = (alarmType == "feu") ? 150 : 350; // Plus rapide pour le feu

    if (millis() - lastLedToggle >= toggleInterval) {
      lastLedToggle = millis();
      ledState = !ledState;
      
      if (ledState) {
        setAllRed();     
      } else {
        clearAllLeds();         
      }
    }
  }
}

void captureAndSave() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) return;
  
  String path = "/photo_" + String(millis()) + ".jpg";
  File file = SD_MMC.open(path.c_str(), FILE_WRITE);
  if (file) {
    file.write(fb->buf, fb->len);
    file.close();
  }
  esp_camera_fb_return(fb);
}

void alarmSound() {
  tone(BUZZER_PIN, alarmFreq);
  alarmFreq += alarmStep;

  if (alarmType == "feu") {
    if (alarmFreq >= 1600 || alarmFreq <= 800) alarmStep = -alarmStep;
  } else {
    if (alarmFreq >= 950 || alarmFreq <= 350) alarmStep = -alarmStep;
  }
  delay(8); 
}

void setAllRed() {
  for (int i = 0; i < NUM_LEDS; i++) {
    pixels.setPixelColor(i, pixels.Color(255, 0, 0)); // Uniquement du Rouge Pur
  }
  pixels.show();
}

void clearAllLeds() {
  pixels.clear();
  pixels.show();
}

void startupAnimation() {
  setAllRed(); // Rouge fixe pendant le démarrage / calibration
  delay(8000); 
  clearAllLeds();
}