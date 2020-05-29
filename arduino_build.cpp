#include <Arduino.h>
#include <UIPEthernet.h>

EthernetClient client;

uint8_t mac[6] = { 0x74, 0x69, 0x69, 0x2D, 0x30, 0x31 };
IPAddress server = IPAddress(192, 168, 0, 105);
int port = 8080;
int size = 0;


void setup(){
    Serial.begin(9600);
    Ethernet.begin(mac);

    Serial.print("IP: "); Serial.println(Ethernet.localIP());
    Serial.print("Subnet: "); Serial.println(Ethernet.subnetMask());
    Serial.print("gateway: "); Serial.println(Ethernet.gatewayIP());
}

void loop(){
    
}