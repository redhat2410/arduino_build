#include <Arduino.h>
#include "Counter.h"

uint8_t CounterTime::l_Counter = 0;
uint8_t CounterTime::l_CounterDoor = 0;
bool    CounterTime::isCount      = false;
bool    CounterTime::isCountDoor  = false;
