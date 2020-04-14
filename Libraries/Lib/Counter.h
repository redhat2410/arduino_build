#ifndef __COUNTER_TIME__
#define __COUNTER_TIME__

/*
  Lop Counter se quan ly tien trinh dem, tien trinh dem nay se thuc hien theo yeu cau cua cac tac vu khac
  VD: se thuc hien dem khi nhấm phim trong tac vu KeyBoard, va thoi gian cho đóng cửa (close door) sau 1
  khoang thoi gian

  Mô tả đối tượng class Counter co cac thuoc tinh nhu:
    - l_counter -> so lan dem cua tac vu
    - isCount   -> cờ dem, đối tuong bat dau dem khi va chi khi cờ (flag) này dc set.
    - static ProcessCount method sẽ dong vai tro nhu phuong thuc thuc hien tang gia tri l_counter.
*/

class CounterTime{
  public:
    static uint8_t l_Counter;
    static uint8_t l_CounterDoor;
    static bool isCount, isCountDoor;

    static void ProcessCount(void){
        //khi isCount is True se thuc hien tang bien l_counter len 1
        if(CounterTime::isCount)
          CounterTime::l_Counter++;
        else CounterTime::l_Counter = 0; //otherwise se reset lai l_count

        if(CounterTime::isCountDoor) CounterTime::l_CounterDoor++;
        else CounterTime::l_CounterDoor = 0;
    }
};

#endif
