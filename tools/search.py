from os import path
from pathlib import Path
import os
import sys

pathHeaderConf = "tools\\etc\\header.conf"
pathFileConf = "tools\\etc\\path.conf"
pathIncludeConf = "tools\\etc\\includes.conf"

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
    word_7 = ""
    #check file header conf is exist, if exist will be remove it
    if path.exists(pathHeaderConf):
        os.remove(pathHeaderConf)
    if path.exists(pathIncludeConf):
        os.remove(pathIncludeConf)
    sources = []
    sources.append(source)
    sources.append(searchCppFile(source))
    #process source file to get header name and write it to log file
    for src in sources:
        if path.exists(src):
            if src.find(".cpp") != -1 or src.find(".c") != -1 :
                word_7 = Path(src).name.replace(".cpp",".h") if src.find(".cpp") else Path(src).name.replace(".c", ".h")
            file = open(src, "r", encoding='utf-8')
            for line in file:
                if line.find(word) == 0 :
                    #get header name
                    if line.find('<') != -1:
                        result = line.split('<')
                        result = result[1].split('>')
                    else:
                        result = line.split('"')
                        result = result[1].split('"')
                    if (result[0] != word_1) and (result[0] != word_2) and (result[0] != word_3) and (result[0] != word_4) and (result[0] != word_5) and (result[0] != word_6) and (result[0] != word_7) :
                        if path.exists(pathIncludeConf):
                            file = open(pathIncludeConf, "r", encoding='utf-8')
                            isFind = False
                            for line in file:
                                if line.find(result[0]) != -1:
                                    isFind = True
                                    break
                                isFind = False                            
                            if not isFind:
                                writeFile(pathIncludeConf, result[0] + "\n")
                            file.close()
                        else:
                            writeFile(pathIncludeConf, result[0] + "\n")
            file.close()       
        else:
            print("Error source file is not exist.")

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
    if path.exists(pathIncludeConf):
        file = open(pathIncludeConf, "r", encoding='utf-8')
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

    for t_path in pathFolder:
        for t_name in headerName:
            for root, dirs, files in os.walk(t_path):
                if t_name in files:
                    #writeFile(pathHeaderConf, root + "\n")
                    if path.exists(pathHeaderConf):
                        file = open(pathHeaderConf, "r", encoding='utf-8')
                        isFind = False
                        for line in file:
                            if line.find(root) != -1:
                                isFind = True
                                break
                            isFind = False
                        
                        if not isFind:
                            writeFile(pathHeaderConf, root + "\n")
                        file.close()
                    else:
                        writeFile(pathHeaderConf, root + "\n")
    
    if path.exists(pathHeaderConf):
        print("Writing " + pathHeaderConf + " done.")
    else:
        print("Writing " + pathHeaderConf + " failed.")


# Hàm searchCppFile có chức năng tìm file .cpp nếu path source là file .h
# @param source: đường dẫn file
# @return 
def searchCppFile(header):
    filename = Path(header).name
    direction= path.dirname(path.abspath(header))
    extension = [".cpp", ".c"]
    t_path = ""
    if filename.find('.h') != -1 :
        for ext in extension:
            filesource = filename.replace('.h', ext)
            for root, dirs, files in os.walk(direction+'\\'):
                if filesource in files:
                    t_path = os.path.join(root, filesource)
    return t_path

if len(sys.argv) > 1:
    searchHeader(sys.argv[1])
    searchPathHeader()
else:
    print("Error no input source file.")

    