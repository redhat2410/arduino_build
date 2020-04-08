Hướng dẫn sử dụng
Require: Đã cài đặt Arduino IDE
    1. Tạo thư mục chứa project
    2. Copy file build_core.bat vào thư mục project
    3. Tạo file chương trình vời định dạng .cpp để cùng cấp với các folder core, inc, Output..
    4. Mở Windows + R -> cmd, chuyển cmd tới thư mục project
    5. Thực hiện chạy file .bat bằng câu lệnh >build_core.bat 

Mô tả tổ chức thư mục
    -   Thư mục core: chứa thư viện cấu trúc của Arduino
    -   Thư mục inc: chứa thư viện được người dùng định nghĩa
    -   Thư mục Libraries: chứa thư viện bao gồm giao thức của Arduino (I2C, SPI, UART)...,
    Ngoài ra thư mục còn chứa thư viện được xây dựng trên cộng đồng.
    -   Thư mục Output: chứa các file chương trình chạy và file nạp cho arduino (elf, hex, o)