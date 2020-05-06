import os.path
import os

arduino = "arduino.exe"
volume = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

drivers = ['%s:'% d for d in volume if os.path.exists('%s:' % d)]

isFind = False

pathArduinoConf = "tools\\etc\\pathArduino.conf"

def writeFile(filename, data):
    if os.path.exists(filename) :
        file = open(filename, "a")
        file.writelines(data)
        file.close()
    else:
        file = open(filename, "w")
        file.writelines(data)
        file.close()



for driver in drivers:
    for root, dirs, files in os.walk(str(driver) + "\\"):
        if arduino in files:
            root = '"' + root + '"'
            writeFile(pathArduinoConf, root)
            isFind = True
            if isFind :
                break
    if isFind:
        break

