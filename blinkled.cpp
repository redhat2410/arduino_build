#include <Arduino.h>

String str = "Hello World";

void setup(){
    Serial.begin(9600);
    str += " Duc";
}

void loop(){
    Serial.println(str);
    delay(1000);
}