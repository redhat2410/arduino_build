#ifndef __RTC__
#define __RTC__

#include <RTClib.h>
#include <Wire.h>
#include <Eeprom24Cxx.h>


/*
  Lop RTC thuc hien ghi log thoi gian thuc cho moi ID, viec ghi log history se duoc dong bo voi server thong qua khoi IOT
    + Viec ghi log se duoc thuc hien moi khi co nguoi scan van tay
    + Viec doc log history se phu thuoc vao khoi IOT khi co yeu cau dong bo
    + Viec xoa log history se duoc thuc hien khi khoi IOT da dong bo xong voi server
*/
//so byte can de luu dia chi ghi Log
#define STORE_ADDRESS 2
//do dai cua 1 decode duoc luu
#define FORMAT_LENGTH 7
//gioi han muc decode duoc luu trong eeprom
#define TOTAL_DECODE  2000
//gia tri max cua eeprom
#define MAX_MEMORY 128*32
//so vung nho can de luu id da dc dang ky trong eeprom
#define STORE_ID  16
//vung nho de luu ID dang ky
#define LOCATE_ID 11
#define FORMAT_TIME 26
//vung nho luu cau hinh cua Alarm
#define LOCATE_CONFIG_ALARM 30
#define CONF_ALARM_SETTING  0
#define CONF_ALARM_ERROR    1
#define CONF_ALARM_TAMPER   2
//dia chi luu gia tri UTC
#define LOCATE_CONF_UTC     31
//So ngay trong thang
const uint8_t daysInMonth [] PROGMEM = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 };


class RTC {
  public:

    static uint16_t addressWrite; // bien static se dinh dia chi ghi vao eeprom
    static uint16_t addressRead;  // bien static se dinh dia chi doc cua eeprom
    static RTC *realtime;
    uint16_t lengthLog(void);//thuc hien tra ve gia tri do dai cua danh sach dang nhap
    char getUTC(void); //thuc hien lay thong tin UTC
    bool writeLog(int ID);//thuc hien ghi lich su dang nhap cua cua nguoi du ve thoi gian va ngay thang
    void readLog(void); // thuc hien doc lich su dang nhap cua nguoi dung duoc luu trong may
    uint8_t* read1Log(void);//thuc hien doc du lieu cua nguoi dung theo kieu hang doi FIFO ( vao truoc ra truoc);
    void clearLog(void); // thuc hien xoa du lieu lich su dang nhap cua nguoi dung khi du lieu da dong bo voi may chu
    void writeID2EEPROM(uint8_t _ID); //thuc hien ghi lai ID da dang ky luu dau van tay
    bool readID2EEPROM(uint8_t _ID); //kiem tra ID da duoc dang ky chua tra ve true khi da dk va false khi chua
    void clearID2EEPROM(uint8_t _ID); //thuc hien xoa dk ID khi thuc hien xoa dau van tay -> se tra ve true khi xoa thanh cong
    //    bool writeEEPROM(uint16_t _address, uint8_t _value); // ham thuc hien ghi vao EEPROM danh cho cac cong viec khac
    //    int readEEPROM(uint16_t _address); // ham thuc hien doc du lieu tu EEPROM danh cho cac cong viec khac
    void configTime(char* command);//ham configureTime cho phep cau hinh lai thoi gian cua RTC
    char* readTime(void); // ham se tra ve thoi gian hien tai cua device khi co yeu cau
    void setConfigAlarm(uint8_t conf);//ham setConfigAlarm se thuc hien luu cau hinh alarm
    void resetConfigAlarm(uint8_t conf);//ham resetConfigAlarm se thuc hien reset cau hinh alarm
    bool statusConfigAlarm(uint8_t conf);//ham doc trang thai hien tai cua cau hinh alarm
    void writeConfigAlarm(uint8_t conf); // ham thuc hien ghi gia tri vao thanh ghi cau hinh alarm tu bit 3 -> 7
    uint8_t readConfigAlarm(void);//doc gia tri cua thanh ghi cau hinh alarm tu bit 3 -> 7
  private:

    // Kiem tra dung luong da luu cua du lieu roi tra ve true or false ( true: day, false: chua day)
    bool checkCapacity(uint16_t address);
    //Ham checkTimeConsecutive kiem tra thoi gian quet 2 lan lien tiep
    bool checkTimeConsecutive( uint8_t* _ID);
};

#endif
