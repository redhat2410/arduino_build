#include <Arduino.h>
#include "Counter.h"
#include "KeyBoard.h"
#include "FingerPrint.h"
#include "Buzzer.h"
#include "Timer.h"
#include "RTC.h"
#include "IOT.h"
#include "WorkScheduler.h"



WorkScheduler *keypadWorkScheduler;
WorkScheduler *fingerPrintWorkScheduler;
WorkScheduler *buzzerWorkScheduler;
WorkScheduler *buzzer1TWorkScheduler;
WorkScheduler *buzzer3TWorkScheduler;
WorkScheduler *verifyFingerWorkScheduler;
WorkScheduler *counterWorkScheduler;
WorkScheduler *openDoorWorkScheduler;
WorkScheduler *iotWorkScheduler;
WorkScheduler *bellWorkScheduler;
WorkScheduler *alarmErrorWorkScheduler;
WorkScheduler *alarmSwitchWorkScheduler;

IOT iot;
KeyBoard kb;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
//  pinMode(13, OUTPUT);
  Timer::getInstance()->initialize();
  keypadWorkScheduler       = new WorkScheduler(10UL,   KeyBoard::Process); // tien trinh thuc hien nhan phim va xu ly phim nhan
  fingerPrintWorkScheduler  = new WorkScheduler(50UL,    FingerPrint::Process); // tien trinh thuc hien scan dau van tay tg thuc hien 50UL
  buzzerWorkScheduler       = new WorkScheduler(20UL,   Buzzer::Alarm); // am bao khi nhan phim thoi gian la 50ms
  buzzer1TWorkScheduler     = new WorkScheduler(1000UL, Buzzer::Alarm1T); // am bao khi thong tin dung tg la 150ms
  buzzer3TWorkScheduler     = new WorkScheduler(100UL,  Buzzer::Alarm3T); // am bao khi thong tin sai  tg la 100ms va thuc keu 3 tieng
  verifyFingerWorkScheduler = new WorkScheduler(10UL,   FingerPrint::ProcessVerify); // tien trinh thuc hien kiem tra hoat dung cua cam bien
  counterWorkScheduler      = new WorkScheduler(500UL,  CounterTime::ProcessCount);
  openDoorWorkScheduler     = new WorkScheduler(5UL,    Buzzer::opencloseDoor);
  iotWorkScheduler          = new WorkScheduler(1UL,    IOT::ProcessIOT);
//  bellWorkScheduler         = new WorkScheduler(500UL,  Buzzer::bellOn);
  alarmErrorWorkScheduler   = new WorkScheduler(100UL,  Buzzer::alarmPeriph_Error);
  alarmSwitchWorkScheduler  = new WorkScheduler(100UL,  Buzzer::alarmPeriph_Tamper);
  iot.init();
  IOT::comFromDevice = false;

//  RTC::realtime->clearLog();
//  RTC::realtime->readLog();
}
void loop() {
//  //Update bo dem thoi gian
  Timer::getInstance()->update();

  //update thoi gian thuc hien cua keypad
  keypadWorkScheduler->update();
  //update thoi gian thuc hien cua scan van tay
  //fingerPrintWorkScheduler->update();

  //update thoi gian lam viec cua Buzzer
  buzzerWorkScheduler->update();
  buzzer1TWorkScheduler->update();
  buzzer3TWorkScheduler->update();

  //update thoi gian lam viec cua tien trinh kiem tran tinh trang hoat dong cua cam bien
  ////  verifyFingerWorkScheduler->update();
  //
  counterWorkScheduler->update();

  openDoorWorkScheduler->update();

  //iotWorkScheduler->update();

  //  bellWorkScheduler->update();
  //
  //  alarmErrorWorkScheduler->update();
  //
  //  alarmSwitchWorkScheduler->update();
  //reset lai thoi gian
  Timer::getInstance()->resetTick();

}
