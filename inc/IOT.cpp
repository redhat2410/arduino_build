#include <Arduino.h>
#include "IOT.h"


#define mySerial Serial
SoftwareSerial Serial1(2, 3);

IOT *IOT::iot = new IOT();
bool IOT::comFromDevice = false;

//************************* Define method for class IOT *************************//
void IOT::init(void) {
  mySerial.begin(9600);
}
bool IOT::available(void) {
  return mySerial.available();
}
/*
  Ham convert2Format chuyen doi thong tin thoi gian sang format chuan do gui sang cho khoi IOT
  @param y  : nam   (year)
  @param M  : thang (month)
  @param d  : ngay  (day)
  @param h  : gio   (hour)
  @param m  : phut  (minute)
  @param s  : giay  (second)
  @param utc: múi gio
  @param id : Id nguoi quet van tay

  Format: yyyy-MM-ddThh:mm:ssTid
*/
char* IOT::convert2Format(uint16_t y, uint8_t M, uint8_t d, uint8_t h, uint8_t m, uint8_t s, char utc, uint8_t id) {
  char *buff = (char*)malloc( (FORMAT_TIME + 3) * sizeof(char) );
  sprintf(buff, "%d-%d-%dT%d:%d:%dT%dT%d", y, M, d, h, m, s, utc, id);
  return buff;
}
/*
  ham cmdLoginUser thuc hien gui lenh tu khoi Device toi khoi IOT
  @param CMD: ma lenh cua
  @param length: do dai cua packet data
  @param data: la chuoi du lieu thoi gian dang nhap cua nguoi dung
  @return: Acknowledge
*/
uint8_t IOT::cmd(uint8_t CMD, uint16_t length, uint8_t *data) {
  uint8_t chksum = 0;
  IOT::comFromDevice = true;
  // thuc hien giu ma lenh va do dai cua packet data
  Packet t_packet(CMD, (uint8_t)(length >> 8), (uint8_t)(length), 0);
  t_packet.writePacket(t_packet);
  // Nhan phan hoi cua khoi IOT
  if ( t_packet.getPacket(&t_packet, 1000) != ACK_SUCCESS) return ACK_FAIL; // khi nhận phản hồi ko day du
  if ( t_packet.parameter[2] != ACK_SUCCESS) return ACK_FAIL; // bên khối IOT phản hồi ko nhận được
  // Neu phan hoi OK thi se thuc hien gui packet data
  //thuc hien gui header
  mySerial.write(HEADER);
  //thuc hien gui packet data va tinh checksum cua data
  for (int i = 0; i < length; i++) {
    mySerial.write(data[i]);
    chksum ^= data[i];
  }
  //gui checksum cua data
  mySerial.write(chksum);
  //thuc hien gui header
  mySerial.write(HEADER);

  IOT::comFromDevice = false;
  return ACK_SUCCESS;
}
/*
  ham cmdBell thuc hien gui lenh bell on tu khoi Device toi khoi IOT
  @param CMD: ma lenh cua bell on OR alarm on
  @return Acknowledge
*/
uint8_t IOT::cmd(uint8_t CMD) {
  IOT::comFromDevice = true;
  Packet t_packet(CMD, 0, 0, 0);
  t_packet.writePacket(t_packet);
  if ( t_packet.getPacket(&t_packet, 5000) != ACK_SUCCESS) return ACK_FAIL; // khi nhận phản hồi ko day du
  if ( t_packet.parameter[2] != ACK_SUCCESS) return ACK_FAIL; // bên khối IOT phản hồi ko nhận được
  IOT::comFromDevice = false;
  return ACK_SUCCESS;
}

//************************* End define method for class IOT *************************//
//************************* Define method for class Packet *************************//

/*
  thuc hien define contructor cua class Packet
  @param command, parameter_1, parameter_2, parameter_3
*/
Packet::Packet(uint8_t command, uint8_t parameter_1, uint8_t parameter_2, uint8_t parameter_3) {
  this->head          = HEADER;
  this->command       = command;
  this->parameter[0]  = parameter_1;
  this->parameter[1]  = parameter_2;
  this->parameter[2]  = parameter_3;
  this->none          = 0x00;
  this->checksum      = this->calc_Checksum(this);
  this->tail          = HEADER;
}
Packet::Packet()  { };
/*
  Ham writePacket thuc hien gui packet thong qua serial
  @param Packet packet la packet can duoc gui di
*/
void Packet::writePacket(Packet packet) {
  mySerial.write(packet.head);
  mySerial.write(packet.command);
  mySerial.write(packet.parameter[0]);
  mySerial.write(packet.parameter[1]);
  mySerial.write(packet.parameter[2]);
  mySerial.write(packet.none);
  mySerial.write(packet.calc_Checksum(&packet));
  mySerial.write(packet.tail);
  delay(1);
}
void Packet::writePacket(uint8_t* buff, uint16_t length) {
  int sum = 0;
  //gui header
  mySerial.write(HEADER);
  for (int i = 0; i < length; i++) {
    //gui packet data
    mySerial.write(buff[i]);
    //thuc hien tinh checksum
    sum ^= buff[i];
  }
  //thuc hien gui checksum
  mySerial.write(sum);
  //thuc hien gui HEADER
  mySerial.write(HEADER);
  delay(1);
}
void Packet::write(uint8_t data){
  mySerial.write(data);
}
/*
  Ham getPacket thuc hien nhan packet tu ben gui
  @param Packet packet: tham so packet se nhan du lieu tu ben gui va ghi vao tham so packet
  @param int timeout:   tham so timeout la tham so timeout thuc hien chờ
*/
uint8_t Packet::getPacket(Packet *packet, uint16_t timeout) {
  uint8_t data;
  uint16_t idx = 0, timer = 0;
  while (true) {
    while (!mySerial.available()) {
      delay(1);
      timer++;
      if (timer > timeout) {
        return ACK_TIMEOUT;
      }
    }
    data = mySerial.read();
    if (idx == 0) {
      if (data != HEADER) return ACK_FAIL;
      packet->head = data;
    }
    else if (idx == 1) packet->command = data;
    else if (idx == 2) packet->parameter[0] = data;
    else if (idx == 3) packet->parameter[1] = data;
    else if (idx == 4) packet->parameter[2] = data;
    else if (idx == 5) packet->none         = data;
    else if (idx == 6) {
      uint16_t t_checksum = packet->command ^ packet->parameter[0] ^ packet->parameter[1] ^ packet->parameter[2] ^ packet->none;
      if ( data != t_checksum) return ACK_FAIL;
      packet->checksum = data;
    }
    else {
      if (data != HEADER) return ACK_FAIL;
      packet->tail = data;
      return ACK_SUCCESS;
    }
    idx++;
  }
  return ACK_FAIL;
}
/*
  Ham getPacket thuc hien nhan du lieu
  @param buff: du lieu nha
  @param length: do dai cua du lieu
*/
uint8_t Packet::getPacket(uint8_t* buff, uint16_t length, uint16_t timeout) {
  uint8_t data = 0, chksum = 0;
  uint16_t timer = 0;
  for (int i = 0; i < length + 3; i++) {
    while (!mySerial.available()) {
      delay(1);
      timer++;
      if (timer > timeout) return ACK_TIMEOUT;
    }
    data = mySerial.read();
    if (i == 0) {
      if (data != HEADER) return ACK_FAIL;
    }
    else if (i < length + 1) {
      buff[i - 1] = data;
      chksum ^= data;
    }
    else if (i == length + 1) {
      if (chksum != data) return ACK_CHECKSUM_FAIL;
    }
    else {
      if (data != HEADER) return ACK_FAIL;
    }
  }
  return ACK_SUCCESS;
}
/*
  Ham calc_Checksum thuc hien tinh checksum cua packet
  thuc hien tinh xor tu byte 2 toi byte 6 cua packet
  Ham se return ve gia tri cua gia tri checksum
*/
uint8_t Packet::calc_Checksum(Packet *packet) {
  return packet->command ^ packet->parameter[0] ^ packet->parameter[1] ^ packet->parameter[2] ^ packet->none;
}
/*
  Ham printPacket co tac dung debug chuong trinh, in gia tri cua packet
  ra Serial monitor
*/
void Packet::printPacket(Packet packet) {
  Serial.print("head:\t"); Serial.println(packet.head, HEX);
  Serial.print("command:\t"); Serial.println(packet.command, HEX);
  Serial.print("parameter 1:\t"); Serial.println(packet.parameter[0], HEX);
  Serial.print("parameter 2:\t"); Serial.println(packet.parameter[1], HEX);
  Serial.print("parameter 3:\t"); Serial.println(packet.parameter[2], HEX);
  Serial.print("none:\t"); Serial.println(packet.none, HEX);
  Serial.print("checksum:\t"); Serial.println(packet.checksum, HEX);
  Serial.print("tail:\t"); Serial.println(packet.tail, HEX);
  Serial.println();
}
//************************* End define method for class Packet *************************//
