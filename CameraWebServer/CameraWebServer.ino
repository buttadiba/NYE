#include <Arduino.h>
#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>

// ===========================
// Select camera model in board_config.h
// ===========================
#include "board_config.h"

// ===========================
// Enter your WiFi credentials
// ===========================
const char *ssid = "mujeeb";
const char *password = "muddassar2017";
//declaration des variables
const int pinPIR = 13;
const int pinBuzzer = 14;
const int pinFeu = 15;  // DO du capteur de flamme
int dernierEtatFeu = -1;


volatile bool surveillanceActive = true;
unsigned long dernierAffichageFeu = 0;

int dernierEtatPIR = -1;
unsigned long debutStabilisationPIR = 0;
bool pirPret = false;
const unsigned long stabilisationPIR = 10000;
const unsigned long delaiAvantAlarme = 10000;
bool compteAReboursActif = false;
bool alarmeActive = false;
unsigned long debutCompteARebours = 0;
unsigned long dernierChangementSirene = 0;
bool sireneAigue = false;

void startCameraServer();
void setupLedFlash();
void envoyerAlerteMouvement(String type, String description) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Alerte non envoyee : Wi-Fi deconnecte");
    return;
  }

  // 1. Créer l’alerte
  HTTPClient http;
  http.begin("http://192.168.1.12:5000/alerts");
  http.setTimeout(15000);
  http.addHeader("Content-Type", "application/json");

  String json =
    "{\"type\":\"" + type + "\","
    "\"title\":\"Alerte NYE\","
    "\"description\":\"" + description + "\"}";

  int code = http.POST(json);
  String reponseAlerte = http.getString();
  http.end();

  Serial.print("Reponse creation alerte : ");
  Serial.println(code);
  Serial.println(reponseAlerte);

  if (code < 200 || code >= 300) {
    Serial.println("Alerte non creee : photo non envoyee.");
    return;
  }

  // 2. Extraire alert_id de la réponse JSON
  int positionId = reponseAlerte.indexOf("\"alert_id\"");
  if (positionId < 0) {
    Serial.println("Impossible de trouver alert_id.");
    return;
  }

  int deuxPoints = reponseAlerte.indexOf(':', positionId);
  if (deuxPoints < 0) {
    Serial.println("Format alert_id invalide.");
    return;
  }

  int debutNombre = deuxPoints + 1;
  while (debutNombre < reponseAlerte.length() &&
         !isDigit(reponseAlerte.charAt(debutNombre))) {
    debutNombre++;
  }

  int finNombre = debutNombre;
  while (finNombre < reponseAlerte.length() &&
         isDigit(reponseAlerte.charAt(finNombre))) {
    finNombre++;
  }

  if (debutNombre == finNombre) {
    Serial.println("Aucun chiffre trouve pour alert_id.");
    return;
  }

  String alertId = reponseAlerte.substring(debutNombre, finNombre);

  // 3. Prendre une photo
  camera_fb_t *photo = esp_camera_fb_get();

  if (photo == nullptr) {
    Serial.println("Echec de la prise de photo.");
    return;
  }

  // 4. Envoyer les octets JPEG au backend
  HTTPClient httpImage;
  String url = "http://192.168.1.12:5000/upload-image?alert_id=" + alertId;

  httpImage.begin(url);
  httpImage.setTimeout(30000);
  httpImage.addHeader("Content-Type", "image/jpeg");

  int codeImage = httpImage.POST(photo->buf, photo->len);

  Serial.print("Reponse envoi photo : ");
  Serial.println(codeImage);

  if (codeImage > 0) {
    Serial.println(httpImage.getString());
  } else {
    Serial.println(httpImage.errorToString(codeImage));
  }

  httpImage.end();
  esp_camera_fb_return(photo);
}


void setup() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();
  pinMode(pinPIR, INPUT);
  pinMode(pinFeu, INPUT_PULLUP);
  pinMode(pinBuzzer, OUTPUT);
  noTone(pinBuzzer);

  debutStabilisationPIR = millis();

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
  config.pin_sccb_sda = SIOD_GPIO_NUM;
  config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.frame_size = FRAMESIZE_UXGA;
  config.pixel_format = PIXFORMAT_JPEG;  // for streaming
  //config.pixel_format = PIXFORMAT_RGB565; // for face detection/recognition
  config.grab_mode = CAMERA_GRAB_WHEN_EMPTY;
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.
  if (config.pixel_format == PIXFORMAT_JPEG) {
    if (psramFound()) {
      config.jpeg_quality = 10;
      config.fb_count = 2;
      config.grab_mode = CAMERA_GRAB_LATEST;
    } else {
      // Limit the frame size when PSRAM is not available
      config.frame_size = FRAMESIZE_SVGA;
      config.fb_location = CAMERA_FB_IN_DRAM;
    }
  } else {
    // Best option for face detection/recognition
    config.frame_size = FRAMESIZE_240X240;
#if CONFIG_IDF_TARGET_ESP32S3
    config.fb_count = 2;
#endif
  }

#if defined(CAMERA_MODEL_ESP_EYE)
  pinMode(13, INPUT_PULLUP);
  pinMode(14, INPUT_PULLUP);
#endif

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t *s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID) {
    s->set_vflip(s, 1);        // flip it back
    s->set_brightness(s, 1);   // up the brightness just a bit
    s->set_saturation(s, -2);  // lower the saturation
  }
  // drop down frame size for higher initial frame rate
  if (config.pixel_format == PIXFORMAT_JPEG) {
    s->set_framesize(s, FRAMESIZE_QVGA);
  }

#if defined(CAMERA_MODEL_M5STACK_WIDE) || defined(CAMERA_MODEL_M5STACK_ESP32CAM)
  s->set_vflip(s, 1);
  s->set_hmirror(s, 1);
#endif

#if defined(CAMERA_MODEL_ESP32S3_EYE)
  s->set_vflip(s, 1);
#endif

// Setup LED FLash if LED pin is defined in camera_pins.h
#if defined(LED_GPIO_NUM)
  setupLedFlash();
#endif

  WiFi.begin(ssid, password);
  WiFi.setSleep(false);

  Serial.print("WiFi connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  startCameraServer();

  Serial.print("Camera Ready! Use 'http://");
  Serial.print(WiFi.localIP());
  Serial.println("' to connect");

}

void loop() {
  if (!surveillanceActive) {
    noTone(pinBuzzer);
    compteAReboursActif = false;
    alarmeActive = false;
    dernierEtatPIR = digitalRead(pinPIR);
    delay(50);
    return;
  }

  if (!pirPret) {
    if (millis() - debutStabilisationPIR >= stabilisationPIR) {
      pirPret = true;
      dernierEtatPIR = digitalRead(pinPIR);
      Serial.println("PIR pret. Passe ta main devant le capteur.");
    }

    delay(50);
    return;
  }
  int etatFeu = digitalRead(pinFeu);

  if (etatFeu != dernierEtatFeu) {
    dernierEtatFeu = etatFeu;

    if (etatFeu == LOW) {
      Serial.println("FLAMME DETECTEE");

      envoyerAlerteMouvement(
          "feu",
          "Feu detecte par le capteur"
      );

      if (!compteAReboursActif && !alarmeActive) {
        debutCompteARebours = millis();
        compteAReboursActif = true;
        Serial.println("Alerte feu envoyee. Alarme dans 10 secondes.");
      }
    } else {
      Serial.println("Aucune flamme");
    }
  }

  int etatCapteur = digitalRead(pinPIR);
  if (etatCapteur != dernierEtatPIR) {
    dernierEtatPIR = etatCapteur;

    if (etatCapteur == HIGH && !compteAReboursActif && !alarmeActive) {
      debutCompteARebours = millis();
      compteAReboursActif = true;

      Serial.println("Mouvement detecte : notification envoyee, delai de 10 secondes.");
      envoyerAlerteMouvement(
          "mouvement",
          "Mouvement detecte par le capteur PIR"
      );
    } else if (etatCapteur == LOW) {
      Serial.println("Mouvement termine. Le delai continue.");
    }
  }

  if (compteAReboursActif &&
      millis() - debutCompteARebours >= delaiAvantAlarme) {
    compteAReboursActif = false;
    alarmeActive = true;
    Serial.println("Delai termine : alarme active jusqu'a la desactivation de NYE.");
  }
  if (alarmeActive && millis() - dernierChangementSirene >= 350) {
    dernierChangementSirene = millis();
    sireneAigue = !sireneAigue;

    if (sireneAigue) {
      tone(pinBuzzer, 1500);
    } else {
      tone(pinBuzzer, 800);
    }
  }

  delay(50);
}
