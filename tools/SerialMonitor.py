import serial

port = input("Enter port name: ")
baud = input("Enter baudrate : ")

ser = serial.Serial(port, baud)

while 1:
    data = ser.read()
    print(data)