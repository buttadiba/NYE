
#include "esp_camera.h"
#include "Arduino.h"
#include "FS.h"
#include "SD_MMC.h"
#include <Adafruit_NeoPixel.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include <WiFi.h>
#include <WebServer.h>

// ==========================================
// CONFIGURATION DU POINT D'ACCÈS (RÉSEAU AP)
// ==========================================
const char* ap_ssid = "ESP32-CAM_Securite"; // Nom du WiFi généré par l'ESP32
const char* ap_password = "SuperPassword123"; // 8 caractères minimum requis

WebServer server(80);

// ==========================================
// CONFIGURATION CORRIGÉE DES BROCHES
// ==========================================
#define PIR_PIN 13      // OK en mode SD 1-bit
#define FLAME_PIN 12    // OK en mode SD 1-bit
#define BUZZER_PIN 15   // OK en mode SD 1-bit
#define LED_PIN 4       // Utilise la broche du flash
#define NUM_LEDS 60

Adafruit_NeoPixel pixels(NUM_LEDS, LED_PIN, NEO_GRB + NEO_KHZ800);

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

// Déclarations des fonctions
void startupAnimation();
void setAllColor(int r, int g, int b);
void alarmSound();
void captureAndSave();
void rainbowFlash();

void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); 
  Serial.begin(115200);
  delay(1000);

  pinMode(PIR_PIN, INPUT);
  pinMode(FLAME_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  pixels.begin();
  pixels.setBrightness(100); 
  pixels.clear();
  pixels.show();

  // ==========================================
  // INITIALISATION DU POINT D'ACCÈS (AP)
  // ==========================================
  // ==========================================
  // INITIALISATION DU POINT D'ACCÈS (AP)
  // ==========================================
  Serial.println("\nConfiguration du Point d'Accès...");
  
  WiFi.mode(WIFI_AP); // Force explicitement le mode Point d'Accès
  delay(200); // Laisse le temps au matériel de changer de mode
  
  // Lancement direct avec l'IP par défaut stable (192.168.4.1)
  if (WiFi.softAP(ap_ssid, ap_password)) {
    Serial.println("Point d'Accès créé avec succès !");
    Serial.print("Nom du WiFi (SSID) : ");
    Serial.println(ap_ssid);
    Serial.print("Adresse IP du serveur : ");
    Serial.println(WiFi.softAPIP());
  } else {
    Serial.println("Échec de la création du Point d'Accès.");
  }
  delay(300); // Pause de sécurité pour stabiliser l'antenne avant la suite


  // ==========================================
  // CONFIGURATION CAMÉRA
  // ==========================================
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
  } else {
    Serial.println("CAMERA OK");
  }

  // ==========================================
  // INITIALISATION SD (MODE 1-BIT IMPÉRATIF)
  // ==========================================
  if (!SD_MMC.begin("/sdcard", true)) {
    Serial.println("ERREUR SD");
  } else {
    Serial.println("SD OK");
  }

  startupAnimation();

  // Page web du serveur
  server.on("/", []() {
    server.send(200, "text/html", "<h1>ESP32 CAMERA ALARME</h1><p>Mode Point d'Acces Actif</p>");
  });
  server.begin();
  Serial.println("Serveur HTTP demarre");
}

void loop() {
  server.handleClient();
  
  int flame = digitalRead(FLAME_PIN);
  if (flame == LOW) {
    Serial.println("FEU DETECTE !!!");
    setAllColor(255, 0, 0);
    alarmSound();
    captureAndSave();
    delay(5000);
    pixels.clear();
    pixels.show();
  }

  int mvt = digitalRead(PIR_PIN);
  if (mvt == HIGH) {
    Serial.println("MOUVEMENT DETECTE");
    alarmSound();
    rainbowFlash();
    captureAndSave();
    pixels.clear();
    pixels.show();
    noTone(BUZZER_PIN);
    delay(3000);
  }
  delay(100);
}

void captureAndSave() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Erreur Capture");
    return;
  }
  String path = "/photo_" + String(millis()) + ".jpg";
  File file = SD_MMC.open(path.c_str(), FILE_WRITE);
  if (!file) {
    Serial.println("Erreur fichier");
  } else {
    file.write(fb->buf, fb->len);
    Serial.print("Photo sauvegardee : ");
    Serial.println(path);
  }
  file.close();
  esp_camera_fb_return(fb);
}

void alarmSound() {
  for (int i = 0; i < 4; i++) {
    tone(BUZZER_PIN, 1500); delay(150);
    tone(BUZZER_PIN, 3000); delay(150);
  }
  noTone(BUZZER_PIN);
}

void rainbowFlash() {
  for (int j = 0; j < 2; j++) {
    setAllColor(255, 0, 0); delay(100);
    setAllColor(0, 255, 0); delay(100);
    setAllColor(0, 0, 255); delay(100);
  }
}

void setAllColor(int r, int g, int b) {
  for (int i = 0; i < NUM_LEDS; i++) {
    pixels.setPixelColor(i, pixels.Color(r, g, b));
  }
  pixels.show();
}

void startupAnimation() {
  setAllColor(0, 255, 0);
  delay(500);
  pixels.clear();
  pixels.show();
}