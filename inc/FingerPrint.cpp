#include <Arduino.h>
#include "FingerPrint.h"

SoftwareSerial mySerial(2, 3);

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

//Contructor and Decontructor
FingerPrint::FingerPrint() { }

FingerPrint::~FingerPrint() { }

bool FingerPrint::isInitialize = false;

/*
  Ham verifyFingerPrint thuc hien kiem tra tinh trang hoat dong cua cam bien
*/
bool FingerPrint::verifyFingerPrint(void) {
  if (finger.verifyPassword()) return true; // return ve true neu cam bien phan hoi
  else return false;  //return ve false neu cam bien ko phan hoi
}

/*
  Ham initializeFingerPrint thuc hien khoi cac thong so ban dau cho doi tuong
*/
bool FingerPrint::initializeFingerPrint(void) {
  //khoi tao cho objet finger
  finger.begin(57600);
  //Kiem tra trang thai cua cam bien
  if (finger.verifyPassword()) {}
  else {
    return false;
  }

  finger.getTemplateCount();
  return true;
}
/*
  Ham addFingerPrint thuc hien them dau van tay vao he thong
  voi tham so la id duoc cap phat cho dau van tay do
  ham se tra ve true or false de thong bao ket thuc .
*/
bool FingerPrint::addFingerPrint(int id) {
  //Ham them dau van tay thuc hien
  if (id == 0) return false; // ID #0 ko san sang trong cam bien.
  return (getFingerPrint2Add(id) == FINGERPRINT_OK) ? true : false;

}

/*
  Ham removeFingerPrint thuc hien xoa dau van tay khoi he thong
  voi tham so la id.
  Ham se return ve true or false de thong bao ket thuc.
*/
bool FingerPrint::removeFingerPrint(int id) {
  int t_state = -1;
  bool isRemove = false;
  t_state = finger.deleteModel(id);
  if (t_state == FINGERPRINT_OK)
    isRemove = true;
  else isRemove = false;

  return isRemove;
}

/*
  Ham checkFingerPrint thuc hien kiem tra dau van co ton tai trong he thong?
  Ham return ve true or false de thong bao co tim thay hay ko
*/
bool FingerPrint::checkFingerPrint(void) {
  //Kiem tra van tay da dc luu trong he thong chua
  int idFinger = getFingerPrintID();
  if (idFinger != finger.fingerID) {
    if (  idFinger == -2) {
      // bao hieu 3 tieng bip de thong bao sai dau van tay
      Buzzer::Alarm2wrong = CALL_ALARM;
    }
    return false;
  }
  else {
    // neu id dung se thuc hien ghi log theo thoi gian thuc
    // thuc hien gio gui thong tin thoi gian cho khoi IOT
    if(!RTC::realtime->writeLog(idFinger)){
      Buzzer::Alarm2wrong = CALL_ALARM;
      return false;
    }
    return true;
  }
}

/*
  Ham getFingerPrintID thuc hien lay dau van tay va tra ve ID cua van tay
  neu ko tim thay ID cua dau van tay thi tra ve -2 or -1
*/
int FingerPrint::getFingerPrintID(void) {
  //Thuc hien lay dau van tay va tra ve

  //Cho lay dau van tay
  unsigned char t_img = finger.getImage();
  if ( t_img != FINGERPRINT_OK) return -1;
  //Nhan dang dau van tay
  t_img = finger.image2Tz();
  if (t_img != FINGERPRINT_OK) return -1;
  //tim id cua dau van tay
  t_img = finger.fingerFastSearch();
  if (t_img != FINGERPRINT_OK) return -2; // neu dau van tay ko tim thay se return ve -2

  return finger.fingerID;
}
/*
  Ham getFingerPrint2Add thuc hien lay dau van tay de luu vao he thong
  tham so cua ham la id de dinh danh cho model dau van tay
*/
int FingerPrint::getFingerPrint2Add(int id) {
  int t_state = -1;
  int t_out = 0;

  
  //kiem tra van tay da duoc dang ky chua
  analogWrite(LED_GREEN_PIN, T_HIGH);
  int t_id = -1;
  while(t_id == -1){
    t_id = getFingerPrintID();
    t_out++;
    if(t_out >= 30) break;
  }
  analogWrite(LED_GREEN_PIN, T_LOW);
  if(t_id == finger.fingerID) return -2;
  else if(t_id == -1) return -2;
  
  //Cho lay mau dau van tay lan thu 1
  while (t_state != FINGERPRINT_OK) {
    t_state = finger.getImage();
    if (t_state == FINGERPRINT_OK) {
      analogWrite(LED_GREEN_PIN, T_LOW);
      analogWrite(LED_RED_PIN, T_LOW);
    }
    else if (t_state == FINGERPRINT_NOFINGER) {
      analogWrite(LED_GREEN_PIN, T_HIGH);
      analogWrite(LED_RED_PIN, T_LOW);
    }
    else {
      analogWrite(LED_RED_PIN, T_HIGH);
      analogWrite(LED_GREEN_PIN, T_LOW);
    }
    t_out++;
    if (t_out >= 30) break;
  }
  t_out = 0;

  //Tien hanh dinh danh cho dau van tay
  t_state = finger.image2Tz(1);
  if (t_state == FINGERPRINT_OK) {
    delay(5);
  }
  else {
    //    Serial.println("Image not converted");
    return t_state;
  }
  Buzzer::Alarm2correct = CALL_ALARM;

  t_state = 0;
  while (t_state != FINGERPRINT_NOFINGER)
    t_state = finger.getImage();

  analogWrite( LED_GREEN_PIN, T_HIGH);
  t_state = -1;
  while (t_state != FINGERPRINT_OK) {
    t_state = finger.getImage();
    if (t_state == FINGERPRINT_OK) {
      analogWrite( LED_GREEN_PIN, T_LOW);
      analogWrite(LED_RED_PIN, T_LOW);
    }
    else if (t_state == FINGERPRINT_NOFINGER) {
      analogWrite( LED_GREEN_PIN, T_HIGH);
      analogWrite(LED_RED_PIN, T_LOW);
    }
    else {
      analogWrite(LED_RED_PIN, T_HIGH);
      analogWrite(LED_GREEN_PIN, T_LOW);
    }
    t_out++;
    if (t_out >= 30) break;
  }

  //tiep tuc chuyen doi hinh anh
  t_state = finger.image2Tz(2);
  if (t_state == FINGERPRINT_OK) {
    delay(5);
  }
  else {
    return t_state;
  }
  t_out = 0;

  //Converted

  t_state = finger.createModel();
  if (t_state == FINGERPRINT_OK) {
  }
  else {
    return t_state;
  }

  t_state = finger.storeModel(id);

  if (t_state == FINGERPRINT_OK) {
  }
  else {
    return t_state;
  }
  Buzzer::Alarm2correct = CALL_ALARM;
  return FINGERPRINT_OK;
}
