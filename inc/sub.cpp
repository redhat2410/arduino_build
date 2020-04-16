#include <sub.h>
RTC_DS3231 rtc;
int sub(int a, int b){
    if (!rtc.begin()){
        Serial.println("Couldn't find RTC");
        while (1);
    }
    return 0;
}