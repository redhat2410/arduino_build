import serial

ser = serial.Serial(port='COM11', baudrate=9600)

while True:
    print(chr(ser.read()))