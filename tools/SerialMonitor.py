import serial
import sys

port = input("Enter port name: ")
baud = input("Enter baudrate : ")

# try:
#     # ser = serial.Serial(port, baud, timeout=1 )

#     while True:
#         k = cv2.waitKey(1) & 0xFF
#         # data = ser.readline().decode('ascii')
#         # if data != "" :
#         #     print(data)
#         print(k)
#         if k == ord('q'):
#             print("quit")
#             break

# except:
#     print("An exception occurred")

ser = serial.Serial(port, baud, timeout = 1)
while True:
    try:
        data = ser.readline().decode('ascii')
    except:
        sys.exit()

    if data != "":
        print(data)