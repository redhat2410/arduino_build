import os.path
import os

arduino = "arduino.exe"
volume = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

drivers = ['%s:'% d for d in volume if os.path.exists('%s:' % d)]
folders = ["Program Files (x86)", "Program Files"]

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
    for folder in folders:
        for root, dirs, files in os.walk(str(driver) + "\\" + folder):
            if arduino in files:
                root = '"' + root + '"'
                writeFile(pathArduinoConf, root)
                isFind = True
                if isFind :
                    break
        if isFind:
            break

