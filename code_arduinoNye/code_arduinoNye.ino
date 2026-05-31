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

bool alertSent = false;

// ✅ AJOUTS CORRECTS (MANQUANTS)
bool pirReady = false;
unsigned long pirStartTime = 0;
int lastMvtState = LOW;
bool alarmActive = false;
bool motionLock = false;
bool flameLock = false;

unsigned long lastMotionTime = 0;
const unsigned long MOTION_COOLDOWN = 30000;

// ==========================================
// CONFIGURATION DU RÉSEAU WIFI
// ==========================================
const char* ssid = "Orange-6B6F";
const char* password = "Y9H2G25H4MH";

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
bool systemRunning = true;
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
#define PWDN_GPIO_NUM 32
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 0
#define SIOD_GPIO_NUM 26
#define SIOC_GPIO_NUM 27
#define Y9_GPIO_NUM 35
#define Y8_GPIO_NUM 34
#define Y7_GPIO_NUM 39
#define Y6_GPIO_NUM 36
#define Y5_GPIO_NUM 21
#define Y4_GPIO_NUM 19
#define Y3_GPIO_NUM 18
#define Y2_GPIO_NUM 5
#define VSYNC_GPIO_NUM 25
#define HREF_GPIO_NUM 23
#define PCLK_GPIO_NUM 22

WebServer server(80);

// Déclarations des fonctions
void connectWiFi();
void startupAnimation();
void setAllRed();
void clearAllLeds();
void alarmSound();
void captureAndSave();
void sendAlert(String type);

void sendPhotoSafe(uint8_t* buf, size_t len) {
  HTTPClient http;
  http.begin("http://192.168.1.112:5000/upload-image");
  http.addHeader("Content-Type", "image/jpeg");

  int response = http.POST(buf, len);

  Serial.print("Photo response: ");
  Serial.println(response);

  http.end();
}

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
  http.begin("http://192.168.1.112:5000/alerts");
  http.setTimeout(2000);
  http.addHeader("Content-Type", "application/json");

  String json = "{\"type\":\"" + type + "\", \"title\":\"Alerte ESP\", \"description\":\"Détection\"}";
  int code = http.POST(json);
  http.end();
}

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  Serial.begin(115200);
  delay(500);
  pirReady = false;


  pixels.begin();
  pixels.show();
  pixels.setBrightness(60);

  connectWiFi();
  pirStartTime = millis();
  pirReady = false;

  pinMode(PIR_PIN, INPUT_PULLDOWN);
  delay(2000);
  pinMode(FLAME_PIN, INPUT);
  delay(2000);

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);


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

  server.on("/", []() {
    String statut = systemEnabled ? "ACTIVE" : "DESACTIVE";
    server.send(200, "text/html", "<h1>ESP32 ALARME</h1><p>Surveillance: " + statut + "</p>");
  });

  server.on("/api/on", []() {
    systemRunning = true;
    systemEnabled = true;


    flameLock = false;
    motionLock = true;
    delay(5000);  // ignore faux départ PIR
    motionLock = false;

    alarmOn = false;
    alarmActive = false;
    alarmType = "";

    noTone(BUZZER_PIN);
    clearAllLeds();

    server.send(200, "application/json", "{\"status\":\"ON\"}");
  });

  server.on("/api/off", []() {
    systemEnabled = false;

    alarmOn = false;
    alarmActive = false;
    alarmType = "";

    motionLock = true;
    flameLock = true;

    noTone(BUZZER_PIN);
    clearAllLeds();

    server.send(200, "application/json", "{\"status\":\"OFF\"}");
  });

  server.begin();
}

void captureAndSave() {
  camera_fb_t* fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera fail");
    return;
  }

  Serial.println("Sending photo...");

  sendPhotoSafe(fb->buf, fb->len);

  esp_camera_fb_return(fb);
}

void alarmSound() {
  if (!systemEnabled) {
    noTone(BUZZER_PIN);
    return;
  }
  tone(BUZZER_PIN, alarmFreq);
  alarmFreq += alarmStep;

  if (alarmType == "feu") {
    if (alarmFreq >= 1600 || alarmFreq <= 800) alarmStep = -alarmStep;
  } else {
    if (alarmFreq >= 950 || alarmFreq <= 350) alarmStep = -alarmStep;
  }
  delay(8);
  yield();
}

void setAllRed() {
  for (int i = 0; i < NUM_LEDS; i++) {
    pixels.setPixelColor(i, pixels.Color(255, 0, 0));
  }
  pixels.show();
}

void clearAllLeds() {
  pixels.clear();
  pixels.show();
}

void startupAnimation() {
  setAllRed();
  for (int i = 0; i < 80; i++) {
    delay(100);
    yield();  // ✅ évite le reset
  }
  clearAllLeds();
}

void loop() {

  server.handleClient();

  if (!pirReady) {
    if (millis() - pirStartTime > 60000) {
      pirReady = true;
      Serial.println("PIR READY");
    } else {
      return;
    }
  }

  if (!systemEnabled) {
    alarmOn = false;
    alarmActive = false;

    noTone(BUZZER_PIN);
    clearAllLeds();

    return;  // 🔥 STOP TOUT ICI
  }

  if (alarmOn && millis() - alarmStartTime >= ALARM_DURATION) {
    alarmOn = false;
    alarmActive = false;
    alertSent = false;
    alarmType = "";

    noTone(BUZZER_PIN);
    clearAllLeds();
  }

  int flameReading = digitalRead(FLAME_PIN);
  int mvtReading = digitalRead(PIR_PIN);

  if (flameReading == HIGH) flameLock = false;
  if (mvtReading == LOW) motionLock = false;

  if (flameReading == LOW && !flameLock && !alarmActive) {

    alarmActive = true;
    flameLock = true;

    Serial.println("FEU DETECTÉ");

    alarmOn = true;
    alarmType = "feu";
    alarmStartTime = millis();

    setAllRed();
    sendAlert("feu");
    captureAndSave();
  }


  static unsigned long motionStart = 0;

  if (mvtReading == HIGH) {

    if (motionStart == 0)
      motionStart = millis();

    if (!motionLock && !alarmActive && millis() - motionStart > 1500) {

      alarmActive = true;
      motionLock = true;
      lastMotionTime = millis();

      Serial.println("MOUVEMENT DETECTÉ");

      alarmOn = true;
      alarmType = "mouvement";
      alarmStartTime = millis();

      setAllRed();
      sendAlert("mouvement");
      captureAndSave();
    }

  } else {
    motionStart = 0;
  }

  // déclenche seulement si stable pendant un petit moment


  if (mvtReading == HIGH && !motionLock && !alarmActive) {

    delay(100);  // anti faux spike
    if (digitalRead(PIR_PIN) == HIGH) {

      alarmActive = true;
      motionLock = true;
      lastMotionTime = millis();

      Serial.println("MOUVEMENT DETECTÉ");

      alarmOn = true;
      alarmType = "mouvement";
      alarmStartTime = millis();

      setAllRed();
      sendAlert("mouvement");
      captureAndSave();
    }
  }

  if (millis() - lastMotionTime > MOTION_COOLDOWN) {
    motionLock = false;
  }

  if (alarmOn) {
    alarmSound();

    unsigned long toggleInterval = (alarmType == "feu") ? 150 : 350;

    if (millis() - lastLedToggle >= toggleInterval) {
      lastLedToggle = millis();
      ledState = !ledState;

      if (ledState) setAllRed();
      else clearAllLeds();
    }
  }
}