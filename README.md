# Trình biên dịch AVR và ESP
Trình biên dịch được sử dụng cho các dòng vi điều khiển AVR và tương thích với các sản phẩm Arduino: Arduino Uno, Nano, Pro Mini ... . Trình biên dịch còn tương thích với các dòng ESP8266 như: ESP8266-v1, ESP8266-v7, ESP8266-v12. Tuy
nhiên phiên bản này chỉ dành cho Windows.
## Cài đặt
Để sử dụng trình biên dịch đầu tiên:
- Thực hiên clone tools hỗ trợ từ github.
- Tạo thư mục chứa dự án.
- Sao chép thư mục tools, build.bat và build_esp.bat vào thư mục chứa dự án.
```bash
git clone https://github.com/redhat2410/arduino_build.git
cd arduino_buid
mkdir new_project
copy -r arduino_build\tools new_project\
copy arduino_build\build.bat new_project\
copy arduino_build\build_esp.bat new_project\
```
sao khi sao chép các thư mục và tập tin cần thiết vào thư mục dự án, sau đó sẽ thực hiện chạy file .bat
- Chạy tập tin build.bat cho các dự án thực hiện trên dòng arduino AVR.
- Chạy tập tin build_esp.bat cho các dự án thực hiện trên dòng ESP8266
```bash
cd new_project
build.bat
build_esp.bat
```
## Bố cục
Sao khi chạy các file .bat thì bố cục trong thư mục dự án sẽ có dạng như sau:
![alt text](https://github.com/redhat2410/arduino_build/tree/master/img/Layout.PNG?raw=true)
- Thư mục core/ : có chức năng chứa các tập tin compile của thư viện lõi của Arduino
- Thư mục inc/  : có chức năng chứa các tập tin thư viện do người lập trình định nghĩa ( .h, .c/.cpp ), ngoài ra còn chứa các tập tin thư viện tĩnh (.a)
- Thư mục libraries/    : có chức năng chứa các tập tin compile của thư viện giao tiếp (SPI, Wire, EEPROM, SoftwareSerial) của Arduino.
- Thư mục output/       : có chức năng chứa các tập tin compile của chương trình chính và các tập tin chạy và nạp chương cho vdk (.elf, .hex, .bin...)
- Thư mục tools/        : có chức năng chứa các công cụ hỗ trợ cho việc biên dịch, yêu cầu không được xóa bất cứ tập tin nào trong thư mục này
- Tập tin new_project.cpp   : tập tin sẽ được tạo ra trong lần chay đầu tin của .bat, tập tin được tạo ra với tên của thư mục chứa nó và với định dạng cpp.
## Sử dụng
## Bản quyền