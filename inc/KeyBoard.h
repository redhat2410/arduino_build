#ifndef __KEYBOARD__
#define __KEYBOARD__

#include <Keypad.h>
#include <EEPROM.h>
#include "FingerPrint.h"
#include "Buzzer.h"
#include "Counter.h"
#include "RTC.h"

#define DEBUG

#define LENGTH 10
#define TOTAL_COMMAND 5

class KeyBoard {
  public:

    char l_PassWord[LENGTH];
    char l_Command[LENGTH * 3];


    //Contructor and DeContructor
    KeyBoard();
    ~KeyBoard();
    //function press button in keyPAD
    int Pressed(void);
    //function checkPassword thuc hien kiem tra password nhap vao co giong nhu trong da luu trong eeprom
    bool checkPassword(char* password);
    //khoi tao password ban dau voi gia tri 12345
    void initPassword(void);
    //ham savePassword thuc hien luu password moi vao eeprom (tam thoi)
    bool savePassword(char *newPassword);
    void readPassword(void);
    //Ham pressedBell se thuc hien doc nut nhan bell tren ban phim
    void pressBell(void);
    // Ham switchTamper se thuc hien kiem tra nut nhan switch tamper
    void switchTamper(void);
    /*
      Ham process thuc hien xu ly nut nhan
      VD:
        Khi thuc hien nhan phim A thi se chuyen sang che don ROOT
        Khi nhan phim B se thuc hien chuyen sang che do normal
      Ham se thuc hien kiem tra cac phim nhan va xu ly theo yeu cau cua requirement
         1234#1#5678
    */

    static void Process(void) {
      //Lay ky tu duoc nhan
      static bool passwordIsTrue        = false; //flag set password is true
      static bool removeAllisTrue       = false; //flag set remove all user
      static bool configureAlarmisTrue  = false; //flag set configure alarm
      //bien dem so lan nhap password admin sai, khi times2wrong >= 3 se thong bao bang coi ALARM
      static uint8_t times2wrong        = 0;
      static int count = 0;
      static KeyBoard keys;
      char key = keys.Pressed();
      //kiem tra nut bell co duoc nhan
      keys.pressBell();
      //kiem tra switch bao dong duoc nha
      keys.switchTamper();


      //thuc hien dem 20s ke tu khi nhan phim
      if (CounterTime::l_Counter >= 20 && !Buzzer::isOpen ) {
        memset(keys.l_Command, 0, LENGTH * 3);
        count = 0;
        CounterTime::l_Counter = 0;
        CounterTime::isCount = false;
        passwordIsTrue = false;
        Buzzer::Alarm2wrong = CALL_ALARM;
      }
      if (key == -1) return;

      //Kiem tra nhan phim #
      if ( key == '#') {
        //Serial.println();
        //Thuc hien dung dem thoi gian reset lai bien dem
        CounterTime::l_Counter = 0;
        CounterTime::isCount   = false;

        //Thuc hien kiem tra password da duoc verify chua??
        if ( !passwordIsTrue ) {
          // Khi password chua duoc verify thi thuc hien kiem tra password
          if (keys.l_Command[0] == '*') { //kiem tra format kiem tra password *password#
            char *t_password = (char*)malloc( LENGTH * sizeof(char));
            sscanf( keys.l_Command, "*%s", t_password); //thuc hien lay password
            if ( keys.checkPassword(t_password)) {
              //neu password dung set bien co (flag) passwordIsTrue is True
              passwordIsTrue = true;
              CounterTime::isCount = true;
              times2wrong = 0;//reset bien dem khi password dung
              Buzzer::Alarm2correct = CALL_ALARM;//bao 1 tieng beep dai thong bao dung
              //Serial.println("password is correct");
            }
            else {
              times2wrong++;//tang so lan sai cua password
              Buzzer::Alarm2wrong = CALL_ALARM;//bao 3 tieng beep thong bao sai
            }
            free(t_password);
          }
          else {
            times2wrong++;//tang so lan sai cua pasword
            Buzzer::Alarm2wrong = CALL_ALARM;//bao 3 tieng beep thong bao sai
          }
          if (times2wrong >= 3)
            Buzzer::alarmIsCall = true;
          else
            Buzzer::alarmIsCall = false;
        }
        else {
          //neu password da verify se thuc hien kiem tra cac command
          /*
             Open Door with password admin
            Syntax: *12345## -> open door
             Administrator operator:
            Press 8:  Change password
            Press 1:  Add user fingerprint
            Press 2:  Remove user fingerprint
            Press 9:  Remove all user -> can phai xac nhan lai de xoa all user  syntax: *1234#9#9# thuc hien xac nhan 2 lan de xoa all users
            Press 4:  Configure unlocking duration (Cau hinh thoi gian unlock) thoi gian cho phep tu 1 -> 10s
            +Confirm by press #
              Configure Alarm
            Press 0 -> Press 1:  Configure alarm setting [enable, disable] alarm  syntax: *1234#0#1(0: enable; 1: disable)
            Press 0 -> Press 2:  Configure error operation triggered alarm
            Press 7:             Configure temper alarm ( cau hinh alarm khi tháo khỏi tường )
            Press 0 -> Press 4:  Configure the time how long would the door sensor to check door status
              ( cau hinh thoi gian kiem tra trang thai cua door )
          */
          if ( keys.l_Command[0] == '8') {
            //Khi command 8 yeu cau change password
            if (!configureAlarmisTrue && !removeAllisTrue) {
              //Serial.println("Change password");
              char *n_password = (char*)malloc( LENGTH * sizeof(char));
              sscanf( keys.l_Command, "8%s", n_password);
              keys.savePassword( n_password); //thuc hien save password
              Buzzer::Alarm2correct = CALL_ALARM;
              free(n_password);
            }
            else {
              //Serial.println("Command is wrong");
              configureAlarmisTrue = false;
              removeAllisTrue = false;
              Buzzer::Alarm2wrong = CALL_ALARM;
            }
          }
          else if (keys.l_Command[0] == '1') {
            if (!removeAllisTrue) {
              //kiem tra xem co yeu cau cau hinh Alarm ko?
              if (configureAlarmisTrue) {
                //Neu co yeu cau cau hinh Alarm
                //Cau hinh Alarm thuc hien cho phep or ko cho phep Alarm duoc enable or disable
                //Serial.println("Cho phep cau hinh alarm");
                int enableDisable = 0; // ( 0: enable; 1: disable)
                sscanf(keys.l_Command, "1%d", &enableDisable);
                // bat tat che do cau hinh Alarm
                if (enableDisable == 1) {
                  Buzzer::configureAlarm = true;
                  RTC::realtime->setConfigAlarm(CONF_ALARM_SETTING);
                }
                else {
                  Buzzer::configureAlarm = false;
                  RTC::realtime->resetConfigAlarm(CONF_ALARM_SETTING);
                }
                Buzzer::Alarm2correct = CALL_ALARM;
                configureAlarmisTrue = false; // reset lai bien flag configureAlarmisTrue
              }
              else {
                //Khi ko co yeu cau cau hinh Alarm
                //Khi command 1 yeu cau add user fingerprint
                //Serial.println("Cau hinh them fingerprint");
                int t_id = 0;
                sscanf(keys.l_Command, "1%d", &t_id);
                if ( t_id > 0 && t_id < 128) {
                  //neu id nam trong khoan (1, 127)
                  if ( !RTC::realtime->readID2EEPROM(t_id)) { //Kiem tra xem id da duoc dang ky chua
                    //neu chua duoc dang ky se thuc hien them dau van tay
                    if (FingerPrint::ProcessAdd(t_id))
                      Buzzer::Alarm2correct = CALL_ALARM;
                    else
                      Buzzer::Alarm2wrong = CALL_ALARM;
                  }
                  else // neu id da dc dang ky thi thong bao id da dang ky nen ko the dang ky tiep
                    Buzzer::Alarm2wrong = CALL_ALARM;
                }
                else
                  //ID khong nam trong khoang 1->127
                  Buzzer::Alarm2wrong = CALL_ALARM;
              }
            }
            else {
              //Serial.println("Command is wrong");
              removeAllisTrue = false;
              Buzzer::Alarm2wrong = CALL_ALARM;
            }
          }
          else if (keys.l_Command[0] == '2') {
            if (!removeAllisTrue) {
              //kiem tra xem co yeu cau cau hinh Alarm ko?
              if (configureAlarmisTrue) {
                if (RTC::realtime->statusConfigAlarm(CONF_ALARM_SETTING)) {
                  //khi co yeu cau cau hinh Alarm
                  //Serial.println("Cau hinh error alarm");
                  int errorTriggerAlarm = 0;
                  sscanf(keys.l_Command, "2%d", &errorTriggerAlarm);
                  //bat tat che do cau hinh error trigger alarm
                  if (errorTriggerAlarm == 1) {
                    Buzzer::errorTriggerAlarm = true;
                    RTC::realtime->setConfigAlarm(CONF_ALARM_ERROR);
                  }
                  else {
                    Buzzer::errorTriggerAlarm = false;
                    RTC::realtime->resetConfigAlarm(CONF_ALARM_ERROR);
                  }
                  Buzzer::Alarm2correct = CALL_ALARM;
                }
                else {
                  //Serial.println("Cau hinh ko duoc phep");
                  Buzzer::Alarm2wrong = CALL_ALARM;
                }
                configureAlarmisTrue = false;
              }
              else {
                //Khi command 2 yeu cau remove user fingerPrint
                //Serial.println("Cau hinh remove user");
                int t_id = 0;
                sscanf(keys.l_Command, "2%d", &t_id);
                if ( t_id > 0 && t_id < 128) {
                  //Khi id nam trong khoang tu 1 -> 127
                  if (RTC::realtime->readID2EEPROM(t_id)) { //Kiem tra xem id da duoc dang ky chua?
                    //neu id da duoc dang ky moi cho xoa
                    if (FingerPrint::ProcessRemove(t_id))
                      Buzzer::Alarm2correct = CALL_ALARM;
                    else
                      Buzzer::Alarm2wrong = CALL_ALARM;
                  }
                  else //Neu Id chua duoc dang ky thi thong bao id chua dc dang ky nen ko the xoa
                    Buzzer::Alarm2wrong = CALL_ALARM;
                }
                else
                  Buzzer::Alarm2wrong = CALL_ALARM;
              }
            }
            else {
              //Serial.println("Command is wrong");
              removeAllisTrue = false;
              Buzzer::Alarm2wrong = CALL_ALARM;
            }
          }
          else if (keys.l_Command[0] == '9') {
            if (!configureAlarmisTrue) {
              //Khi command 9 yeu cau remove all user
              if (!removeAllisTrue) { //kiem tra flag removeAllisTrue da dc set chua
                //Serial.println("Cau hinh remove all user xin xac nhan 1 lan nua");
                //neu chua duoc set se thuc hien set bien co va reset lai cac bien l_Command
                removeAllisTrue = true;
                memset(keys.l_Command, 0, LENGTH * 3);
                count = 0;
                return;
              }
              else {
                //Serial.println("Cau hinh remove all user");
                //nguoc lai neu flag removeAllisTrue da duoc set, thi thuc hien xoa tat ca user
                for (int id = 1; id < ALL_USER; id++) { //duyet toan bo user
                  if (RTC::realtime->readID2EEPROM(id)) //kiem tra id da duoc dang ky
                    FingerPrint::ProcessRemove(id);//neu id da duoc dang ky thi se tien hanh xoa id va fingerPrint
                }
                Buzzer::Alarm2correct = CALL_ALARM;
                removeAllisTrue = false; //reset lai bien flag removeAllisTrue
              }
            }
            else {
              //Serial.println("Command is wrong");
              configureAlarmisTrue = false;
              Buzzer::Alarm2wrong = CALL_ALARM;
            }
          }
          else if (keys.l_Command[0] == '4') {
            if (!removeAllisTrue) {
              if (configureAlarmisTrue) {
                if (RTC::realtime->statusConfigAlarm(CONF_ALARM_SETTING)) {
                  //Serial.println("Cau hinh thoi gian kiem tra trang thai cua");
                  //khi co yeu cau cau hinh Alarm
                  int times2CheckStatus = 0;
                  sscanf(keys.l_Command, "4%d", &times2CheckStatus);
                  //thuc hien cau hinh thoi gian kiem tra trang thai cua door
                  if (times2CheckStatus > 1 && times2CheckStatus < 255) { // thoi gian cho phep duoc cau hinh tu 1 -> 254s
                    Buzzer::times2CheckDoor = times2CheckStatus;
                    RTC::realtime->writeConfigAlarm(times2CheckStatus);
                    Buzzer::Alarm2correct = CALL_ALARM;
                  }
                  else Buzzer::Alarm2correct = CALL_ALARM;
                }
                else {
                  //Serial.println("Cau hinh ko duoc phep");
                  Buzzer::Alarm2wrong = CALL_ALARM;
                }
                configureAlarmisTrue = false;
              }
              else {
                //Khi command 4 yeu cau cau hinh thoi gian
                //Serial.println("Cau hinh thoi gian unlock");
                int timeUnlock = 0;
                sscanf( keys.l_Command, "4%d", &timeUnlock);
                //kiem tra thoi gian cau hinh trong khoang tu 1 -> 10s
                if ( timeUnlock > 0 && timeUnlock <= 10) {
                  // neu thoi gian cau hinh trong khoang tu 1 -> 10
                  Buzzer::time2Unlock = timeUnlock;//thiet lap thoi gian unlock
                  Buzzer::Alarm2correct = CALL_ALARM; //thiet lap thoi gian thanh cong
                }
                else Buzzer::Alarm2wrong = CALL_ALARM;
              }
            }
            else {
              //Serial.println("Command is wrong");
              removeAllisTrue = false;
              Buzzer::Alarm2wrong = CALL_ALARM;
            }
          }
          else if (keys.l_Command[0] == '7') {
            if (!configureAlarmisTrue && !removeAllisTrue) {
              if (RTC::realtime->statusConfigAlarm(CONF_ALARM_SETTING)) {
                //khi command 7 yeu cau cau hinh enable disable alarm temper
                //Serial.println("Cau hinh cho phep bao dong gia");
                int enableDisableTamper = 0;
                sscanf(keys.l_Command, "7%d", &enableDisableTamper);
                Buzzer::switchTamperAlarm = (enableDisableTamper == 1) ? true : false;
                if (enableDisableTamper == 1) {
                  Buzzer::switchTamperAlarm = true;
                  RTC::realtime->setConfigAlarm(CONF_ALARM_TAMPER);
                }
                else {
                  Buzzer::switchTamperAlarm = false;
                  RTC::realtime->setConfigAlarm(CONF_ALARM_TAMPER);
                }
                Buzzer::Alarm2correct = CALL_ALARM;
              }
              else {
                //Serial.println("Cau hinh ko duoc phep");
                Buzzer::Alarm2wrong = CALL_ALARM;
              }
              configureAlarmisTrue = false;
            }
            else {
              //Serial.println("Command is wrong");
              Buzzer::Alarm2wrong = CALL_ALARM;
              configureAlarmisTrue = false;
              removeAllisTrue = false;
            }
          }
          else if (keys.l_Command[0] == '0') {
            if (!configureAlarmisTrue && !removeAllisTrue) {
              //Khi command 0 yeu cau cau hinh Alarm
              configureAlarmisTrue = true;//thuc hien set bien co flag configureAlarmisTrue
              memset( keys.l_Command, 0, LENGTH * 3);
              count = 0;
              return;
            }
            else {
              //Serial.println("Command is wrong");
              Buzzer::Alarm2wrong = CALL_ALARM;
              configureAlarmisTrue = false;
              removeAllisTrue = false;
            }
          }
          else if ((int)keys.l_Command[0] == 0) {
            //khi muon mo cua bang password admin syntax: *12345##
            Buzzer::isOpen = true;
            CounterTime::l_CounterDoor = 0;
            Buzzer::Alarm2correct = CALL_ALARM;
            //Serial.println("Open Door");
          }
          else {
            //Serial.println("Command is wrong");
            Buzzer::Alarm2wrong = CALL_ALARM;
            configureAlarmisTrue = false;
            removeAllisTrue = false;
          }
          // Sau khi thuc hien xong cac command reset passwordIsTrue
          passwordIsTrue = false;
        }

        memset( keys.l_Command, 0, LENGTH * 3);
        count = 0;
      }
      else {
        if (!CounterTime::isCount) CounterTime::isCount = true;
        else CounterTime::l_Counter = 0;
//        Serial.print(key);
        //luu gia tri phim nhan trong vao bien l_Command
        keys.l_Command[count] = key;
        Buzzer::Alarm2click = CALL_ALARM;
        count++;
      }

    }
};

#endif
