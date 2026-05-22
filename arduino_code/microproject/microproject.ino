#include <Adafruit_NeoPixel.h>

// Pins
int buzz = 12;
int pirPin = 13;

#define LED_PIN 3
#define LED_COUNT 300

bool alarmOn = false;
int freq = 400;
int step = 15;

Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  Serial.begin(115200);

  pinMode(pirPin, INPUT);

  Serial.println("Calibration PIR...");
  delay(30000); // IMPORTANT
  Serial.println("Pret !");

  ledcAttach(buzz, freq, 8);

  strip.begin();
  strip.show();
  strip.setBrightness(100);
}

void loop() {

  if (!alarmOn) {
    int motion = digitalRead(pirPin);

    if (motion == HIGH) {
      Serial.println("MOUVEMENT DETECTE !");
      alarmOn = true;
    }

    delay(100);

  } else {

    // Sirène
    ledcWriteTone(buzz, freq);
    freq += step;

    if (freq >= 1200 || freq <= 400) {
      step = -step;
    }

    // LEDs
    fillAll(strip.Color(255, 0, 0));
    delay(500);

    fillAll(strip.Color(0, 0, 0));
    delay(500);
  }
}

void fillAll(uint32_t color) {
  for (int i = 0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, color);
  }
  strip.show();
}