#ifndef __BUZZER__
#define __BUZZER__

/*
  Lop Buzzer thuc hien xu ly buzzer de thuc hien keu tieng bip theo yeo cau
  cau hinh cho buzzer pin A0 cua arduino pro mini
*/

#include "Counter.h"
#include "IOT.h"
#include "RTC.h"

#define T_HIGH 512
#define T_LOW   0

#define CALL_ALARM  0

#define BUZZER_PIN    A0
#define LED_GREEN_PIN A1
#define LED_RED_PIN   13
#define BELL_IN       A2
#define BELL_OUT      A3
#define SWITCH        A6
#define DOOR          11
#define ALARM_PERIPH  12

class Buzzer {
  public:
    static uint8_t Alarm2click;   // cờ set khi thuc thi tac vu am bao click
    static uint8_t Alarm2wrong;   // cờ set khi thuc thi tac vu am bao sai
    static uint8_t Alarm2correct; // cờ set khi thuc thi tac vu am bao dung
    static bool    isOpen;        // co yeu cau open door
    static uint8_t time2Unlock;   //thoi gian mo khoa gia tri defaul 10s
    // Cac bien trong cau hinh ALARM
    static bool    configureAlarm;  //co configure Alarm cho phep thiet lap Alarm
    static bool    switchTamperAlarm; //flag status switch Tamper Alarm
    static bool    isSwitchOn;
    static bool    errorTriggerAlarm;
    static uint8_t times2CheckDoor;
    static bool    alarmIsCall;
    // Cac bien trong cau hinh Bell
    static bool    isBellOn;

    /*
      Tac vu thuc hien âm bao khi nhan phim, am bao nay chi thuc hien 1 lan ON -> OFF
    */
    static void Alarm(void) {
      static bool wasLightedUp = false;
      if (Alarm2click < 2) {
        analogWrite(BUZZER_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        analogWrite(LED_GREEN_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        wasLightedUp = !wasLightedUp;
        Alarm2click++;
      }
      else {
        Alarm2click = 2;
        wasLightedUp = false;
      }
    }
    /*
      Tac vu thuc hien am bao khi tiep nhan thong tin sai, am se thong bao 3 tieng bip lien tuc
    */
    static void Alarm3T(void) {
      static bool wasLightedUp = false;
      if ( Alarm2wrong < 6) {
        analogWrite(BUZZER_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        analogWrite(LED_RED_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        wasLightedUp = !wasLightedUp;
        Alarm2wrong++;
      }
      else {
        Alarm2wrong = 6;
        wasLightedUp = false;
      }
    }
    /*
      Tac vu thuc hien âm bao khi tiep nhan thong tin dung, am bao nay chi thuc hien 1 lan ON -> OFF
    */
    static void Alarm1T(void) {
      static bool wasLightedUp = false;
      if ( Alarm2correct < 2) {
        analogWrite(BUZZER_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        analogWrite(LED_GREEN_PIN, !wasLightedUp ? T_HIGH : T_LOW);
        wasLightedUp = !wasLightedUp;
        Alarm2correct++;
      }
      else {
        Alarm2correct = 2;
        wasLightedUp = false;
      }
    }
    /*
      Tac vu opencloseDoor thuc hien dong mo relay nhu 1 cach dong mo cua phong
      tac vu nay thuc hien khi co (flag) isOpen dc set se thuc hien mo relay va sau khoang thoi gian 20s
      dong relay
    */
    static void opencloseDoor(void) {
      //kiem tra flag isOpen
      if (Buzzer::isOpen) {
        // neu thoi gian dem lớn hon (large than) time2Unlock
        if (CounterTime::l_CounterDoor > time2Unlock) {
          //se thuc hien reset lai bien dem va ben isOpen
          CounterTime::l_CounterDoor = 0;
          CounterTime::isCountDoor = false;
          Buzzer::isOpen = false;
          digitalWrite( DOOR, LOW);
        }
        //nguoc lai neu thoi gian nho hon 20s se thuc hien mo relay
        else
        {
          CounterTime::isCountDoor = true; // thuc hien cho phep dem
          digitalWrite( DOOR, HIGH);
        }
      }
    }
    /*
      Tac vu bellOn co nhiem vu dieu khien trigger ngo ra Bell_OUT dieu khien ngoai vi
    */
    static void bellOn(void) {
      //kiem tra bien isBellOn da duoc set
      if (Buzzer::isBellOn) {
        analogWrite( BELL_OUT, T_HIGH); // dieu khien ngoai vi
//        Serial.write("B:on"); // gui thong bao bell on toi khoi IOT
        IOT::iot->cmd(CMD_BELL);
      }
      else analogWrite(BELL_OUT, T_LOW);
    }
    /*
      Tac vu alarmPeripheral cho phep dieu khien còi hú ngoại vi cho chuc nang bao loi
    */
    static void alarmPeriph_Error(void) {
      //kiem tra da enable cau hinh error va da cho phep CALL_ALARM
      if ( Buzzer::errorTriggerAlarm && Buzzer::alarmIsCall) {
        digitalWrite( ALARM_PERIPH, HIGH); //trigger cho còi hú ngoai vi (kich mach cong suat)
//        Serial.println("A:on");//thuc hien gui thong bao cho khoi IOT
        IOT::iot->cmd(CMD_ALARM);
        
      }
      else {
        digitalWrite(ALARM_PERIPH, LOW);
      }
    }
    /*
      Tac vu alarmPeripheral_Tamper cho phep dieu khien coi hu ngoai vi cho chuc nang bao khi thao thiet
      bi ra khoi tuong
    */
    static void alarmPeriph_Tamper(void) {
      //kiem tra da enable cau hinh tamper va da cho call alarm
      if ( Buzzer::switchTamperAlarm && !Buzzer::isSwitchOn) {
        digitalWrite( ALARM_PERIPH, HIGH); //trigger cho coi hu ngoai vi (kich mach cong suat)
//        Serial.println("A:on");//thuc hien gui thong bao cho khoi IOT
        IOT::iot->cmd(CMD_ALARM);
      }
      else {
        digitalWrite(ALARM_PERIPH, LOW);
      }
    }
};

#endif
