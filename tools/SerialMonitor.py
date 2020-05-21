import serial
import sys
import time

port = input("Enter port name: ")
baud = input("Enter baudrate : ")

ser = serial.Serial(port, baud, timeout=1)

while True:
    try:
        data = ser.readline().decode('ascii')
    except:
        sys.exit()
    if data != "":
        print(data)
