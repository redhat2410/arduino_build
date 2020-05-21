import serial

port = input("Enter port name: ")
baud = input("Enter baudrate : ")

try:
    ser = serial.Serial(port, baud)

    while 1:
        data = ser.read()
        print(data)
except:
    print("An exception occurred")