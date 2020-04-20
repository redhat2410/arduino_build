#include <Arduino.h>
#include "KeyBoard.h"

/*
  So do noi chan ban phim

  |*|                 |D|
  12 10 09 08 07 06 05 04

*/

const byte rows = 4;
const byte columns = 3;

int p_Time2Hold = 300;
int p_State = 0;
int p_Key = 0;

//char keys[rows][columns] = {
//  {'1', '2', '3', 'A'},
//  {'4', '5', '6', 'B'},
//  {'7', '8', '9', 'C'},
//  {'*', '0', '#', 'D'},
//};
char keys[rows][columns] = {
  {'1', '2', '3'},
  {'4', '5', '6'},
  {'7', '8', '9'},
  {'*', '0', '#'},
};

//char keys[rows][columns] = {
//  {'*', '0', '#'},
//  {'7', '8', '9'},
//  {'4', '5', '6'},
//  {'1', '2', '3'},
//};

byte rowPins[rows] = {7, 6, 5, 4};
byte columnPins[columns] = {10, 9, 8};

Keypad keypads = Keypad(makeKeymap(keys), rowPins, columnPins, rows, columns);

//define contructor
KeyBoard::KeyBoard() {}
//define decontructor
KeyBoard::~KeyBoard() {}

/*
  Ham Pressed thuc hien kiem tra phim nao dang duoc nhan
  Ham Pressed ra ve ky tu duoc nhan
*/
int KeyBoard::Pressed(void) {
  char t_pressed = keypads.getKey();
  //Kiem tra phim dang dc nhan
  if ((int)keypads.getState() == PRESSED)
    if (t_pressed != 0) p_Key = t_pressed;
  //Kiem tra phim dc tha
  if ((int)keypads.getState() == RELEASED) {
    delay(100);
    return p_Key;
  }
  //Khi ko co phim nao dc nhan ham se return ve -1
  return -1;
}
/*
  Ham checkpasswork thuc hien kiem tra password duoc nhap tu ban phim voi
  password dc luu trong eeprom giong nhau hay ko tra ve true or false
*/
bool KeyBoard::checkPassword(char *password) {

  int len = strlen(password);
  char *t_oldpassword = (char*)malloc( len * sizeof(char));
  bool ret = true;
  if ( len > EEPROM.read(10)) return false;
  for (int i = 0; i < EEPROM.read(10); i++)
    t_oldpassword[i] = EEPROM.read(i);
  //thuc hien kiem tra password duoc nhap va password duoc luu
  for (int i = 0; i < EEPROM.read(10); i++)
    if ( password[i] != t_oldpassword[i] ) ret = false;
  free(t_oldpassword);
  return ret;
}
/*
  Ham initPassword thuc hien khoi tao 1 password mac dinh cho vao eeprom
  gia tri defaul: 12345

  Vung trong EEPROM duoc duoc danh de luu password co dia chi tu 0 -> 9

*/
void KeyBoard::initPassword(void) {
  // password mac dinh
  char *passDefault = "12345";
  for (int i = 0; i < LENGTH; i++)
    EEPROM.write(i, passDefault[i]);
  EEPROM.write(10, strlen(passDefault));
  free(passDefault);
}
/*
  Ham savePassword thuc hien luu password moi vao eeprom
  voi tham so la password moi, gia tri tra ve la true or false
*/
bool KeyBoard::savePassword(char* password) {
  // Thuc hien ghi password moi vao eeprom
  // Luu lai thong tin do dai cua password
  int len = strlen(password);
  EEPROM.write( 10, len);

  for (int i = 0; i < len; i++) {
    EEPROM.write(i, password[i]);
  }
  // reset nhung vung nho con lai trong eeprom dc cap phat cho password
  for (int i = len; i < LENGTH; i++)
    EEPROM.write(i, 0);//reset gia tri
  return true;
}
/*
  Ham readPassword thuc hien doc password trong eeprom, ham nay o modify private nen chi dung de
  debug chuong trinh
*/
void KeyBoard::readPassword(void) {
  //thuc hien doc vung nho cua eeprom tu 0 -> 9 (vùng nhớ để lưu password)
  for (int i = 0; i < EEPROM.read(10); i++) {
    Serial.print((char)EEPROM.read(i));
  }
  Serial.println();
}
/*
  Ham pressBell thuc hien kiem tra nut bell tren ban phim da duoc nhan chua
  neu nhan thi set bien isBellon nguoc lai thi reset bien isBellon
*/
void KeyBoard::pressBell(void) {
  //kiem tra nut bell_in
  if (digitalRead(BELL_IN) == HIGH) {
    delay(5);
    while (digitalRead(BELL_IN) == HIGH) {} // cho cho toi khi tha nut
    Buzzer::isBellOn = true; // thuc hien set bien isBellOn
  }
  else Buzzer::isBellOn = false; // thuc hien reset bien isBellOn
}
/*
  Ham switchTamper se kiem tra cong tac bao dong co duoc  nhan ko
  neu nhan thi set bien switchTamperAlarm nguoc lai thi reset switchTamperAlarm
*/
void KeyBoard::switchTamper(void) {
  //kiem tra switch co duoc nhan
  if (analogRead(A6) > 675) {
    Buzzer::isSwitchOn = true;
  }
  else Buzzer::isSwitchOn = false;
}
