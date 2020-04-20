#ifndef __IOT__
#define __IOT__

/*
  Class IOT co nhiem vu giao tiep voi khoi IOT thong qua Serial port
  nhiem vu cua lop IOT la tiep nhan cac len tu IOT gui toi va phan hoi lai

  lop IOT co 1 tien trinh chay song song voi cac tien trinh khac co tac dung
  lien tuc chờ (wait) lenh (command) tu khoi IOT gui toi va phan hoi lai

  Cac cong viec cua class IOT can lam
    + Nhan lenh tu khoi IOT
    + gui cho khoi IOT thoi gian dang nhap
    + gui cho khoi IOT log history
    + cho phep khoi IOT cau hinh thoi gian

  format command:
    config    1#2019-12-17T17:44:30\n ( format lenh cau hinh thoi duoc gui tu khoi IOT)
    getTime   2#\n                    ( lenh gui yeu cau device cung cap thoi gian hien tai cua device) YYYY-MM-DDThh:mm:ss
    readLog   3#\n                    ( format lenh doc Log tu khoi IOT)
    clearLog  4#\n                    ( lenh gui yeu cau device xoa history log )
    reset     5#\n                    ( lenh gui yeu cau khoi phuc tinh trang goc cua device)
    2019-12-17T17:44:30TID        ( format lenh gui tu device cho khoi IOT) YYYY-MM-DDThh:mm:ssTID
*/
#include "RTC.h"
#include <SoftwareSerial.h>




#define LENGTH_FORMAT   26
#define LENGTH_COMMAND  10
#define LENGTH_PARAM    20

/********COMMAND********/
#define CMD_CONF_TIME   0x01
#define CMD_GET_TIME    0x02
#define CMD_READ_LOG    0x03
#define CMD_CLEAR_LOG   0x04
#define CMD_RESET       0x05
#define CMD_LOGIN_USER  0x06
#define CMD_BELL        0x07
#define CMD_ALARM       0x08

/********ACKNOWLEDGE********/
#define ACK_SUCCESS       0x00
#define ACK_FAIL          0x01
#define ACK_TIMEOUT       0x02
#define ACK_CHECKSUM_FAIL 0x03

#define HEADER          0xF5

typedef struct Time_Fid {
  String dates;
  int utc;
  int f_id;
  Time_Fid(char* buff) {
    int years, months, days, hours, minutes, seconds, t_utc, t_id;
    sscanf( buff, "%d-%d-%dT%d:%d:%dT%dT%d", &years, &months, &days, &hours, &minutes, &seconds, &t_utc, &t_id);
    char* temp = (char*)malloc( 23 * sizeof(char));
    sprintf( temp, "%d-%d-%dT%d:%d:%d", years, months, days, hours, minutes, seconds);
    this->dates = String(temp);
    this->utc = t_utc;
    this->f_id = t_id;
  }
};

class Packet {
  public:
    uint8_t head      = 0;
    uint8_t command   = 0;
    uint8_t parameter[3];
    uint8_t none      = 0;
    uint8_t checksum  = 0;
    uint8_t tail      = 0;
    Packet( uint8_t command, uint8_t parameter_1, uint8_t parameter_2, uint8_t parameter_3);
    Packet();
    //ham writePacket thuc hien gui packet thong qua serial
    void write(uint8_t data);
    void writePacket(Packet packet);
    void writePacket(uint8_t* buff, uint16_t length);
    //ham getPacket thuc hien gui packet thong qua serial
    uint8_t getPacket(Packet *packet, uint16_t timeout);
    uint8_t getPacket(uint8_t* buff, uint16_t length, uint16_t timeout);
    void printPacket(Packet packet);
    //ham calc_Checksum thuc hien tinh checksum tu byte 2 toi byte 6 (thuc hien tinh xor)
    uint8_t calc_Checksum(Packet *packet);
};
class IOT {
  public:
    static IOT *iot;
    static bool comFromDevice;
    char format[LENGTH_FORMAT];
    int  command;
    char parameter[LENGTH_PARAM];
    //Ham convert2Format thuc hien chuyen thong tin thoi gian cho dung voi Format roi gui cho khoi IOT
    char* convert2Format(uint16_t y, uint8_t M, uint8_t d, uint8_t h, uint8_t m, uint8_t s, char utc, uint8_t id);
    //ham init thuc hien khoi tao doi tuong Serial
    void init(void);
    bool available(void);
    //ham cmd thuc hien gui command voi do dai va data
    uint8_t cmd( uint8_t CMD, uint16_t length, uint8_t *data);
    uint8_t cmd(uint8_t CMD);
    static void ProcessIOT(void) {
      Packet t_packet;
      uint16_t ack = 0, length = 0;
      uint8_t* buff;
      if ( !IOT::comFromDevice && (IOT::iot->available() != 0) ) {
        if ( (ack = t_packet.getPacket( &t_packet, 1000)) != ACK_TIMEOUT) {
          //t_packet.printPacket(t_packet);
          if (t_packet.command == CMD_CONF_TIME) {
            //khi IOT gui lenh cau hinh thoi gian (CMD_CONF_TIME)
            //lay thong tin ve do dai cua packet data
            length = (t_packet.parameter[0] << 8) | t_packet.parameter[1];
            buff = (uint8_t*)malloc( length * sizeof(uint8_t));
            //khoi tao packet de phan hoi lai cho khoi IOT
            Packet s_packet( t_packet.command, t_packet.parameter[0], t_packet.parameter[1], ack);
            s_packet.writePacket(s_packet);
            if (s_packet.getPacket(buff, length, 10000) == ACK_SUCCESS) {
              //neu packet nhan OK se lay packet data de cau hinh thoi gian
              RTC::realtime->configTime((char*)buff);
            }
          }
          else if (t_packet.command == CMD_GET_TIME) {
            //khi IOT gui lenh lay thoi gian (CMD_GET_TIME)
            char* readtime = RTC::realtime->readTime();
            length = strlen(readtime);
            //chuan bi packet response de gui
            Packet gt_packet(t_packet.command, (uint8_t)(length >> 8), (uint8_t)length, ack);
            //send response packet
            gt_packet.writePacket(gt_packet);
            //thuc hien gui packet data thoi gian hien tai
            gt_packet.writePacket((uint8_t*)readtime, length);
          }
          else if (t_packet.command == CMD_READ_LOG) {
            int sum = 0;
            length = RTC::realtime->lengthLog() * LENGTH_FORMAT;
            Packet s_packet(t_packet.command, (uint8_t)(length >> 8), (uint8_t)length, ack);
            //gui response toi khoi IOT
            s_packet.writePacket(s_packet);
            //thuc hien gui danh sach lich su dang nhap
            s_packet.write(HEADER);
            for (int i = 0; i < RTC::realtime->lengthLog(); i++) {
              uint8_t* buff = RTC::realtime->read1Log();
              //chuyen doi format
              char* str = IOT::iot->convert2Format( buff[5], buff[4], buff[3], buff[0], buff[1], buff[2], RTC::realtime->getUTC(), buff[6]);
              for (int i = 0; i < strlen(str); i++) {
                s_packet.write((uint8_t)str[i]);
                sum ^= str[i];//thuc hien tinh checksum
              }
              //ket thuc moi decode se bang ky tu enter
              s_packet.write(10);
              sum ^= 10;
              delay(1);
            }
            s_packet.write(sum);
            s_packet.write(HEADER);
          }
          else if (t_packet.command == CMD_CLEAR_LOG) {
            //kiem tra ACK neu SUCCESS se thuc hien xoa lich su dang nhap
            if ( ack == ACK_SUCCESS) RTC::realtime->clearLog();
            //chuan bi packet de send response
            Packet s_packet(t_packet.command, t_packet.parameter[0], t_packet.parameter[1], ack);
            //thuc hien send packet response
            s_packet.writePacket(s_packet);
          }
          else if (t_packet.command == CMD_RESET) {
          }
          else {}
        }
      }
    }
};

#endif
