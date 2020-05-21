import serial
import sys

try:
    port = input("Enter port name: ")
    baud = input("Enter baudrate : ")

    try:
        ser = serial.Serial(port, baud)
    except serial.serialutil.SerialException:
        print("Name port is wrong")
        sys.exit()

    while 1:
        try:
            data = ser.readline().decode('ascii')
        except KeyboardInterrupt:
            sys.exit()

        if data != "":
            print(data)
except KeyboardInterrupt:
    print("\nProgram is exit\n")
    sys.exit(0)
