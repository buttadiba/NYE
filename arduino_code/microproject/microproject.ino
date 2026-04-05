int buzz = 12;
int pirPin = 13;

bool alarmOn = false;
int freq = 400;
int step = 3;

void setup() {

  pinMode(pirPin, INPUT);

  // PWM buzzer ESP32
  ledcAttach(buzz, freq, 8);

  Serial.begin(115200);
}

void loop() {

  if (!alarmOn) {

    int motion = digitalRead(pirPin);
    Serial.println(motion);
  
    if (motion == HIGH) {   // Mouvement détecté
      alarmOn = true;
    }

    delay(50);
  }

  else {

    // Sirène oscillante
    ledcWriteTone(buzz, freq);

    freq += step;

    if (freq >= 1200 || freq <= 100) {
      step = -step;
    }

    delay(10);
  }
}