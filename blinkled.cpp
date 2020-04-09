#include <Arduino.h>

#include <SoftwareSerial.h>
#include < Adafruit_Fingerprint.h >
#include <DS1307.h>

SoftwareSerial mySerial(2, 3);

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

void setup(){
    Serial.begin(9600);
}

void loop(){
}