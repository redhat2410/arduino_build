// Date and time functions using a DS3231 RTC connected via I2C and Wire lib
#include <Arduino.h>
#include <Adafruit_Fingerprint.h>
#include <add.h>

SoftwareSerial mySerial(2, 3);

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

void setup () {
  Serial.begin(9600);
  finger.begin(57600);
  delay(5);
  if (finger.verifyPassword()) {
    Serial.println("Found fingerprint sensor!");
  } else {
    Serial.println("Did not find fingerprint sensor :(");
    // while (1) { delay(1); }
  }
  _sub(1,2);
}

void loop () {
  delay(1000);
}