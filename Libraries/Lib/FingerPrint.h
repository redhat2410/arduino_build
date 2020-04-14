#ifndef __FINGERPRINT__
#define __FINGERPRINT__
#include <Adafruit_Fingerprint.h>
#include "Buzzer.h"
#include "Counter.h"
#include "RTC.h"

#define DEBUG

/*
  Lop FingerPrint thuc hien quan ly cac phuong thuc va thuoc tinh cua
  cam bien dau van tay nhu:
    + Scan dau van tay
    + Them dau van tay
    + Xoa dau van tay
    + Kiem tra dau van tay

  Doi tuong fingerPrint se thuc hien chay 3 tien trinh trong chuong trinh chinh
    + tien trinh scan dau van tay
    + tien trinh add dau van tay
    + tien trinh remove dau van tay
*/
#define ALL_USER  127

class FingerPrint {
  public:
    //ham tao va ham huy cua lop FingerPrint
    FingerPrint();
    ~FingerPrint();
    static FingerPrint *fingerPrint;
    static bool isInitialize;

    //Ham initializeFingerPrint thuc hien khoi tao doi tuong
    bool initializeFingerPrint(void);
    //Ham addFingerPrint thuc hien them dau van tay.
    bool addFingerPrint(int id);
    //Ham removeFingerPrint thuc hien xoa dau van tay.
    bool removeFingerPrint(int id);
    //Ham checkFingerPrint thuc hien kiem tra dau van tay da co trong he thong ko
    bool checkFingerPrint(void);
    //Ham verifyFingerPrint thuc hien kiem tra tinh trang hoat dong cua cam bien
    bool verifyFingerPrint(void);
    //Ham Process thuc hien scan dau van tay day la ham static
    static void Process(void) {
      //bien t_cout thuc hien khong che chi khoi tao cho doi tuong fingerPrint 1 lan
      if (!FingerPrint::isInitialize) {
        if (fingerPrint->initializeFingerPrint()) FingerPrint::isInitialize = true;
        else {
          FingerPrint::isInitialize = false;
          return;
        }
      }
      //Ham check van tay duoc call trong tien trinh xu ly cua main
      // neu check dung se mo cua va uu time log cua nguoi dung roi dong bo voi server
      if (fingerPrint->checkFingerPrint())
      {
        //Open Door in 20 second
        Buzzer::isOpen = true;
        CounterTime::l_CounterDoor = 0;
        Buzzer::Alarm2correct = CALL_ALARM;
      }
      // khi kiem tra dung dau van tay se thong bao "xin cam on"
    }
    // ham ProcessAdd thuc hien tien trinh them dau van tay tien trinh nay se duoc thuc hien trong qua 1 trigger goi tu
    // doi tuong KeyBoard isAddFingerPrint
    static bool ProcessAdd(int id) {
      //Kiem tra cam bien FingerPrint sensor da duoc khoi tao chua
      bool ret = false;

      if (!FingerPrint::isInitialize) {
        //neu chua khoi tao thi phai khoi tao cam bien roi moi thuc hien them dau van tay
        if (fingerPrint->initializeFingerPrint()) FingerPrint::isInitialize = true; //danh dau cam bien da dc khoi tao thanh cong
        else {
          FingerPrint::isInitialize = false;
          return false;
        }
      }
      //neu cam bien da duoc khoi tao thi bat dau thuc hien them dau van tay
      if ( fingerPrint->addFingerPrint(id)) {
        RTC::realtime->writeID2EEPROM(id);//thuc hien them id vao he thong dang ky
        ret = true; //return true khi them thanh cong
      }
      else {
        ret = false; //return false khi them ko thanh cong
      }

      return ret;
    }
    // Ham ProcessRemove thuc hien tien trinh xoa dau tay tien trinh nay se duoc thuc hien trong qua 1 trigger goi tu
    // doi tuong KeyBoard isRemoveFingerPrint
    static bool ProcessRemove(int id) {
      //Kiem tra cam bien FingerPrint sensor da duoc khoi tao chua?
      bool ret = false;

      if ( !FingerPrint::isInitialize ) {
        //Neu cam bien chua duoc khoi tao thi se tien hanh khoi tao cam bien
        if (fingerPrint->initializeFingerPrint()) FingerPrint::isInitialize = true; //danh dau cam bien da dc khoi tao thanh cong
        else {
          FingerPrint::isInitialize = false;
          return false;
        }
      }
      //neu cam bien da duoc khoi tao thi bat dau thuc hien xoa dau van tay
      if (fingerPrint->removeFingerPrint(id)) {
        RTC::realtime->clearID2EEPROM(id); //thuc hien xoa id khoi he thong dang ky
        ret = true; // return ve true khi xoa thanh cong
      }
      else ret = false; // return ve false khi xoa ko thanh cong

      return ret;
    }
    // Ham ProcessVerify la 1 tien trinh chay song song voi cac task vu khac de kiem tra tình trang hoat dong cua
    // cam bien
    static void ProcessVerify(void) {
      if (fingerPrint->verifyFingerPrint()) FingerPrint::isInitialize = true;
      else
      {
        FingerPrint::isInitialize = false;
        // Reset lai buzzer va led khi finger bi treo
        analogWrite(BUZZER_PIN, 0);
        analogWrite(LED_GREEN_PIN, 0);
        analogWrite(LED_RED_PIN, 0);
      }
    }
  protected:
    //ham lay dau van tay va tra ve ID cua model
    int getFingerPrintID(void);
    // Ham lay dau van de thuc them vao
    int getFingerPrint2Add(int id);
};

#endif
