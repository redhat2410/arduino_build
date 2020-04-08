#include <Arduino.h>
#include <SoftwareSerial.h>


SoftwareSerial mySerial(2, 3);

void setup(){
    Serial.begin(9600);
    mySerial.begin(9600);
}

void loop(){
    mySerial.println("Hello");
    delay(1000);
}