#include <Arduino.h>
#include "Buzzer.h"

uint8_t Buzzer::Alarm2click       = 2;
uint8_t Buzzer::Alarm2wrong       = 6;
uint8_t Buzzer::Alarm2correct     = 2;
bool    Buzzer::isOpen            = false;
uint8_t Buzzer::time2Unlock       = RTC::realtime->readConfigAlarm();
bool    Buzzer::configureAlarm    = RTC::realtime->statusConfigAlarm(CONF_ALARM_SETTING);
bool    Buzzer::switchTamperAlarm = RTC::realtime->statusConfigAlarm(CONF_ALARM_TAMPER);
bool    Buzzer::errorTriggerAlarm = RTC::realtime->statusConfigAlarm(CONF_ALARM_ERROR);
uint8_t Buzzer::times2CheckDoor   = 0;
bool    Buzzer::isBellOn          = false;
bool    Buzzer::isSwitchOn        = false;
bool    Buzzer::alarmIsCall       = false;
