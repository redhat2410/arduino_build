#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <webServer.h>
#include <mathLib.h>
#include <BlinkLed.h>

ESP8266WebServer server(80);

char* ssid = "TT-Viethas";
char* pass = "0909925354";

void handleRootPath();

void setup(){
    Serial.begin(115200);
    connect_wifi(ssid, pass);
    server.on("/", handleRootPath);
    server.begin();
}

void loop(){
    server.handleClient();
}

void handleRootPath(){
    server.send(200, "text/plain", "Hello ESP8266\n");
}