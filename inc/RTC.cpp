#include <Arduino.h>
#include "RTC.h"
#include "IOT.h"

uint16_t RTC::addressWrite = 2; //declare bien addressWrite is 2
uint16_t RTC::addressRead  = 2; //declare bien addressRead  is 2
RTC *RTC::realtime = new RTC();

RTC_DS3231 rtc;


//int t_result[FORMAT_LENGTH];

static Eeprom24C eeprom(32, 0x57);//Khoi tao eeprom

/*
  ham writeLog thuc hien ghi thoi gian quet van tay vao eeprom voi tham so la ID cua van tay
  format thong tin de ghi vao eeprom như sau: HHmmDDMMYYID ( HH: hour, mm: minute, DD: day, MM: month, YY: year, ID: id finger )
*/
bool RTC::writeLog(int ID) {
  DateTime now = rtc.now();

  uint8_t str[FORMAT_LENGTH];
  //ghi du lieu thoi gian theo format HHmmDDMMYYID
  str[0] = now.hour();
  str[1] = now.minute();
  str[2] = now.second();
  str[3] = now.day();
  str[4] = now.month();
  str[5] = (uint8_t)((now.year() % 100));//???
  str[6] = ID;
  char utc = EEPROM.read(LOCATE_CONF_UTC);

  //Thuc hien gui du lieu thong tin thoi gian cho khoi IOT
  char *format = IOT::iot->convert2Format(str[5] + 2000 , str[4], str[3], str[0], str[1], str[2], utc, str[6]);
  IOT::iot->cmd(CMD_LOGIN_USER, strlen(format), format);
  
  //Thuc hien ghi du lieu vao eeprom
  if ( !checkTimeConsecutive(str)) {
    RTC::addressWrite = eeprom.read_2_byte( 0 );
    if ( !checkCapacity(RTC::addressWrite) ) {
      for (int i = 0; i < FORMAT_LENGTH; i++) {
        eeprom.write_1_byte( RTC::addressWrite, str[i]);//ghi tuan tu du lieu vao eeprom
        RTC::addressWrite++;//thuc hien tang bien dia chi len 1
      }
      eeprom.write_2_byte( 0, RTC::addressWrite);
      return true; // ghi thanh cong se tra ve true
    }
    else {
      return false; //ghi ko thanh cong se tra ve false ( do dung luong chua da day)
    }
  }//khi 2 lan quet lien tiep nho hon 1p thu se ko gui thong tin cho IOT va ko save EEPROM
  //nhung van thong bao quet OK va OPEN DOOR
  else return false;
}
/*
  ham readLog se thuc hien doc toan bo history log cua may quet van tay truoc khi dong bo voi may chu
*/
void RTC::readLog(void) {
  //Ham readlog tam thoi co chuc nang doc toan bo du lieu trong lich su dang nhap ra
  RTC::addressRead = 2;
  IOT iot;
  uint16_t readAddress = eeprom.read_2_byte(0);
  char utc = EEPROM.read(LOCATE_CONF_UTC);
  Serial.println(readAddress);
  for (int i = 0; i < lengthLog(); i++) {
    uint8_t* result = read1Log();
    Serial.println(i);
    Serial.println(iot.convert2Format( result[5] + 2000, result[4], result[3], result[0], result[1], result[2], utc, result[6]));
    delay(10);
    free(result);
  }
}
/*
  Ham clearLog se thuc hien khi xoa du lieu lich su dang nhap cua nguoi dung
*/
void RTC::clearLog(void) {
  //  for (int i = 0; i < 30720; i++)
  //    //set lai vung nho trong eeprom thanh 0
  //    eeprom.write_1_byte( i, 0);
  //reset hai bien luu dia chi doc va ghi
  RTC::addressWrite = 2;
  RTC::addressRead = 2;
  //su dung 2 byte cho viec luu dia chi ghi eeprom
  eeprom.write_1_byte(0, 0);
  eeprom.write_1_byte(1, 2);
}

/*
  Ham read1Log thuc hien doc du lieu trong lich su dang nhap cua nguoi dung theo tung hang va theo dang hang doi FIFO
*/
uint8_t* RTC::read1Log(void) {
  // kiem tra da co du lieu de doc chua
  uint8_t* result = (uint8_t*)malloc( FORMAT_LENGTH * sizeof(uint8_t));
  //neu da co du lieu thuc hien tien hanh doc du lieu trong eeprom theo tung byte
  for ( int i = 0; i < FORMAT_LENGTH; i++) {
    result[i] = eeprom.read_1_byte( RTC::addressRead); // doc du lieu theo dia chi duoc luu trong addressRead
    RTC::addressRead++; // thuc hien tang dia chi len 1
  }

  return result;
}
/*
  Ham lengthLog thuc hien tra ve do dai cua danh sach lich su dang nhap
*/
uint16_t RTC::lengthLog(void) {
  //doc so byte da ghi
  uint16_t length = eeprom.read_2_byte(0);
  //thuc hien tinh va tra ve do dai cua danh sach dang nhap
  return (length - 2) / FORMAT_LENGTH;
}
/*
  Ham getUTC thuc hien lay thong tin UTC
*/
char RTC::getUTC(void) {
  //doc thong utc
  return (char)EEPROM.read(LOCATE_CONF_UTC);
}

/*
  Ham checkCapacity thuc hien kiem tra dung luong da day chua de co the tiep tuc ghi
  ham se tra ve true neu kiem tra da day
  va tra ve false neu chua
*/
bool RTC::checkCapacity(uint16_t address) {
  if ( address >= TOTAL_DECODE * FORMAT_LENGTH) return true;
  else return false;
}
/*
  Ham writeEEPROM se thuc hien ghi du lieu vao EEPROM o vi tri danh cho cong viec khac
  ham se tra ve true khi ghi thanh cong
  va se tra ve fasle khi ghi ko thanh cong -> co the do luu v
*/
//bool RTC::writeEEPROM(uint16_t _address, uint8_t _value) {
//  if ( _address > MAX_MEMORY || //kiem tra dia chi co vuot qua gia tri cho phep cua eeprom
//       ( _address >= 0 && _address <= LOCATE_ID - 1 ) )//|| // ko cho phep ghi trong vung nho danh cho Loggin history
////       ( _address >= LOCATE_ID && _address <= LOCATE_ID + STORE_ID) ) // ko cho phep ghi trong vu ngho danh cho dang ky ID
//    return false; // neu xay 1 trong 3 truong hop se tra ve false thong bao ko the ghi dc
//  else {
//    eeprom.write_1_byte( _address, _value);
//    return true;
//  }
//}

/*
  Ham readEEPROM se thuc hien doc du lieu EEPROM o vi tri danh cho cong viec khac
  ham se tra ve gia tri cua cho phep va tra ve -1 cho khi doc nhung vung nho ko cho phep
*/
//int RTC::readEEPROM( uint16_t _address) {
//  if ( _address > MAX_MEMORY || //kiem tra dia chi co vuot qua gia tri cho phep cua eeprom
//       ( _address >= 0 && _address <= LOCATE_ID - 1 ) )//|| // ko cho phep ghi trong vung nho danh cho Loggin history
////       ( _address >= LOCATE_ID && _address <= LOCATE_ID + STORE_ID) ) // ko cho phep ghi trong vu ngho danh cho dang ky ID
//    return -1; // neu xay 1 trong 3 truong hop se tra ve -1 thong bao ko the ghi dc
//  else
//    return eeprom.read_1_byte( _address);//doc gia tri cua dung nho dc phep
//}
/*
  Ham writeID2EEPROM se thuc hien dang ky ID voi he thong
  tham so dau vao la _ID can ghi
*/
void RTC::writeID2EEPROM( uint8_t _ID) {
  uint8_t locate = (uint8_t)(_ID / 8); // xac dinh ID nay se dc ghi vao byte nao trong 16 byte danh cho ID
  // sau khi xac dinh dc vi tri luu, toi thu tu luu cua ID trong byte
  uint8_t shiftbit = _ID - ( locate * 8 );

  uint8_t value = 0;
  //thuc hien dang ky ID voi he thong ID dc dang ky se co gia tri 1
  value = EEPROM.read(LOCATE_ID + locate) | ( 0x01 << shiftbit);
  EEPROM.write( LOCATE_ID + locate, value);
}
/*
  Ham readID2EEPROM se thuc hien kiem tra _ID da duoc dang ky voi
  he thong chua, neu da dang ky se tra ve true, neu chua la false
*/
bool RTC::readID2EEPROM(uint8_t _ID) {
  uint8_t locate = (uint8_t)(_ID / 8); // xac dinh ID nay se dc ghi vao byte nao trong 16 byte danh cho ID
  // sau khi xac dinh dc vi tri luu, toi thu tu luu cua ID trong byte
  uint8_t shiftbit = _ID - ( locate * 8 );
  uint8_t value = ( EEPROM.read( LOCATE_ID + locate ) >> shiftbit ) & 0x01;
  return (value == 1) ? true : false;
}
/*
  Ham clearID2EEPROM se thuc hien xoa dang ky cua ID voi he thong
  ham nay se tra ve true neu xoa thanh cong va nguoc lai
*/
void RTC::clearID2EEPROM(uint8_t _ID) {
  uint8_t locate = _ID / 8; // xac dinh ID nay se dc ghi vao byte nao trong 16 byte danh cho ID
  // sau khi xac dinh dc vi tri luu, toi thu tu luu cua ID trong byte
  uint8_t shiftbit = _ID - ( locate * 8 );
  uint8_t value = EEPROM.read( LOCATE_ID + locate ) & ( 0xFE << shiftbit);
  EEPROM.write( LOCATE_ID + locate, value); // ghi lai gia tri moi cho vung nho
}
/*
  Ham checkTimeConsecutive thuc hien kiem tra thong tin nguoi quet trong 2 lan quet lien
  tiep khong it hon 1p
  @param format thong tin nguoi quet gom thoi gian va ngay thang
  ham tra ve gia tri true khi 2 quet nhỏ hơn or bằng 1p
  ham tra ve gia tri false khi 2 quet lớn hơn 1p
*/
bool RTC::checkTimeConsecutive(uint8_t* format) {
  RTC::addressRead = 2;
  bool isID = false;
  int seconds, t_seconds;
  int address = 0, t_cmp = 0;
  t_seconds = (format[1] * 60) + format[2];
  //bat dau duyet tu thang gan nhat duyet khoang ???
  address = eeprom.read_2_byte(0) - STORE_ID;
  address /= FORMAT_LENGTH;
  address = address - 1; //giam di 1 vi bat dau chay tu 0
  //dau tien thuc hien kiem tra ngay thang, sau do toi thoi gian neu thoi gian > 60 thi thoat, sau do toi id
  while (!isID) {
    RTC::addressRead = address * FORMAT_LENGTH + STORE_ID;
    uint8_t* t_result = read1Log();
    // kiem tra ngay thang nam cac mau gan nhat
    if ( (format[3] == t_result[3] ) && (format[4] == t_result[4]) && (format[5] == t_result[5]) )  {
      if ( format[0] == t_result[0] ) { // kiem tra gio cua mau gan nhat
        seconds = (t_result[1] * 60) + t_result[2]; // doi phut ra giay
        if ( (t_seconds - seconds) <= 60) { // kt giay <= 60s
          if ( format[6] == t_result[6]) {
            return true; // kt id neu trung id se thong bao la quet lien tiep
          }
        }
        else return false;
      }
      else return false;
    }
    else return false;
    address--;
  }
}

/*
  Ham configTime thuc hien cau hinh lai thoi gian cua RTC
  @param char* command "2019-12-12T11:32:50"
  cac tham so nay cho chuc nang cap nhat thoi gian moi
*/
void RTC::configTime(char* command) {
  uint16_t years;
  int days, months, hours, minutes, seconds;
  char utc;
  //Tach chuoi ra cac bien ve nam thang ngay, gio phut giay
  sscanf(command, "%d-%d-%dT%d:%d:%dT%d", &years, &months, &days, &hours, &minutes, &seconds, &utc);
  //clear vung nho cua UTC
  EEPROM.write(LOCATE_CONF_UTC, 0);
  //Luu gia tri cua utc vao eeprom
  EEPROM.write(LOCATE_CONF_UTC, utc);
  // Thuc hien update thoi gian theo ngay gio moi
  rtc.adjust( DateTime(years, months, days, hours, minutes, seconds));
}
/*
  Ham readTime se thuc hien tra ve thoi gian cua RTC khi co
  yeu cau tu khoi IOT
*/
char* RTC::readTime(void) {
  char* buff = (char*)malloc( FORMAT_TIME * sizeof(char));
  //lay thong tin thoi gian va ngay thang hien tai
  DateTime now = rtc.now();
  uint16_t years = now.year() + 2000; // convert to format 2019
  uint8_t months, days, hours, minutes, seconds;
  char utc = EEPROM.read(LOCATE_CONF_UTC);
  months  = now.month();
  days    = now.day();
  hours   = now.hour();
  minutes = now.minute();
  seconds = now.second();
  //Chuyen doi thong tin thoi gian va ngay thang theo format da quy dinh
  sprintf( buff, "%d-%d-%dT%d:%d:%dT%dT", years, months, days, hours, minutes, seconds, utc);

  return buff;
}
/*
  Ham setConfigAlarm thuc hien set bit 1 vung nho khi co yeu cau set cau hinh alarm
  co 3 config alarm can luu y:
    CONF_ALARM_SETTING
    CONF_ALARM_ERROR
    CONF_ALARM_TAMPER
  add LOCATE_CONFIG_ALARM |Time to unlock|CAS|CAE|CAT|
  CAS: CONF_ALARM_SETTING
  CAE: CONF_ALARM_ERROR
  CAT: CONF_ALARM_TAMPER
*/
void RTC::setConfigAlarm(uint8_t conf) {
  uint8_t value = EEPROM.read( LOCATE_CONFIG_ALARM ) | (0x01 << conf); //set vung nho tung bit
  EEPROM.write( LOCATE_CONFIG_ALARM, value);//luu cau hinh moi
}
/*
  Ham resetConfigAlarm thuc hien ghi bit 0 vao vung nho khi co yeu cau
*/
void RTC::resetConfigAlarm(uint8_t conf) {
  uint8_t value = EEPROM.read(LOCATE_CONFIG_ALARM) & (0xFE << conf); //reset vung nho theo tung bit
  EEPROM.write(LOCATE_CONFIG_ALARM, value);
}
/*
  Ham statusConfigAlarm thuc hien doc trang thai cua vung nho cau hinh
*/
bool RTC::statusConfigAlarm(uint8_t conf) {
  uint8_t value = ( EEPROM.read(LOCATE_CONFIG_ALARM) >> conf ) & 0x01;
  return (value == 1) ? true : false; //thuc hien doc gia tri tung bit neu bit co gia tri 0 se false 1 se true
}
/*
  Ham writeConfigAlarm thuc hien ghi cau hinh vao thanh ghi alarm config tu bit 3 -> 7
  param conf gia tri se duoc ghi vao thanh ghi
*/
void RTC::writeConfigAlarm(uint8_t conf) {
  uint8_t value = (EEPROM.read(LOCATE_CONFIG_ALARM) & 0x07) | (conf << 3);
  EEPROM.write(LOCATE_CONFIG_ALARM, value); //ghi lai gia tri moi vao thanh ghi cau hinh alarm
}
/*
  Ham readConfigAlarm thuc hien doc cau hinh tu thanh ghi alarm config tu bit 3 -> 7
  Ham se tra ve gia tri cua thanh ghi tu bit 3 -> 7
*/
uint8_t RTC::readConfigAlarm(void) {
  uint8_t value = (EEPROM.read(LOCATE_CONFIG_ALARM) >> 3);
  return value;
}
