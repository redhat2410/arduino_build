from os import path
import os
import sys

pathHeaderConf = "tools\\etc\\header.conf"
pathFileConf = "tools\\etc\\path.conf"

# function searchHeader implement search header name have been included in source file
# @param source : path to source file
def searchHeader(source):
    word = "#include"
    word_1 = "Arduino.h"
    word_2 = "Software.h"
    word_3 = "Wire.h"
    word_4 = "SPI.h"
    word_5 = "HID.h"
    word_6 = "EEPROM.h"
    #check file header conf is exist, if exist will be remove it
    if path.exists(pathHeaderConf):
        os.remove(pathHeaderConf)
    #process source file to get header name and write it to log file
    if path.exists(source):
        file = open(source, "r", encoding='utf-8')
        for line in file:
            if line.find(word) == 0 :
                #get header name
                result = line.split('<')
                result = result[1].split('>')
                if (result[0] != word_1) and (result[0] != word_2) and (result[0] != word_3) and (result[0] != word_4) and (result[0] != word_5) and (result[0] != word_6) :
                    writeFile(pathHeaderConf, result[0]+"\n")
        file.close()       
    else:
        print("error source file is not exist.")

def writeFile(filename, data):
    if path.exists(filename) :
        file = open(filename, "a")
        file.writelines(data)
        file.close()
    else:
        file = open(filename, "w")
        file.writelines(data)
        file.close()

# Hàm searchPathHeader thực hiện tìm đường dẫn của các header trong file source
# sau khi tìm được sẽ ghi lại vào file header.conf để comipler có thể đọc và xử
# các header sẽ được tìm trong 2 thư mục được định nghĩa trong file path.conf
#
def searchPathHeader():
    #check file path.conf is exist
    pathFolder = []
    headerName = []
    if path.exists(pathFileConf):
        file = open(pathFileConf, "r", encoding='utf-8')
        for line in file:
            t_str = line.split('\n')
            if t_str[0].find('"') != -1:
                t_str = t_str[0].split('"')
                pathFolder.append(t_str[1])
            else:
                pathFolder.append(t_str[0])
        file.close()
    else:
        print("Error configure file is not exist.")
        return
    #check file header.conf is exist
    if path.exists(pathHeaderConf):
        file = open(pathHeaderConf, "r", encoding='utf-8')
        for line in file:
            t_str = line.split('\n')
            if t_str[0].find('"') != -1:
                t_str = t_str[0].split('"')
                headerName.append(t_str[1])
            else:
                headerName.append(t_str[0])
        file.close()
    else:
        print("Error configure file is not exist.")
        return

    os.remove(pathHeaderConf)
    for t_path in pathFolder:
        for t_name in headerName:
            for root, dirs, files in os.walk(t_path):
                if t_name in files:
                    writeFile(pathHeaderConf, root + "\n")
    
    if path.exists(pathHeaderConf):
        print("Writing " + pathHeaderConf + " done.")
    else:
        print("Writing " + pathHeaderConf + " failed.")


if len(sys.argv) > 1:
    searchHeader(sys.argv[1])
    searchPathHeader()
else:
    print("Error no input source file.")

    