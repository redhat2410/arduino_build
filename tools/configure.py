from os import path
from pathlib import Path
import os
import sys


pathBackupInc= "tools\\etc\\backupInc.conf"
pathBackupLib= "tools\\etc\\backupLib.conf"
pathIncludeConf="tools\\etc\\includes.conf"
pathHeaderConf="tools\\etc\\header.conf"
pathIncludes = "inc\\"
pathIncludesLib = "inc\\lib\\"
pathOutput = "output\\"
headerNameInc = []
headerNameLib = []
headerPath = []
headerFullPath = []
headerFullPathLib = []
headerFullPathInc = []

def isExist(List, find):
    exist = False
    for l in List:
        if l == find :
            exist = True
            break
    return exist

# Hàm search sẽ tìm kiếm tất cả các file header có liên qua tới file source
# @param source: file nguồn 
# @param none
def search(source):
    #define word compare
    word = "#include"
    word_1 = "Arduino.h"
    word_2 = "SoftwareSerial.h"
    word_3 = "Wire.h"
    word_4 = "SPI.h"
    word_5 = "HID.h"
    word_6 = "EEPROM.h"
    word_7 = ""
    #-------------------
    #kiem tra file source co ton tai
    if path.exists(source):
        if source.find(".cpp") != -1 or source.find(".c") != -1 :
            word_7 = Path(source).name.replace(".cpp",".h") if source.find(".cpp") else Path(source).name.replace(".c", ".h")

        file = open(source, "r", encoding='utf-8')
        for line in file:
            if line.find(word) == 0:
                #get header name
                if line.find('<') != -1:
                    result = line.split('<')
                    result = result[1].split('>')
                else:
                    result = line.split('"')
                    result = result[1].split('"')
                #ignore header special
                if (result[0] != word_1) and (result[0] != word_2) and (result[0] != word_3) and (result[0] != word_4) and (result[0] != word_5) and (result[0] != word_6) and (result[0] != word_7) :
                    if not isExist(headerNameInc, result[0]):
                        headerNameInc.append(result[0])
                        print(result[0])
        file.close()
    else:
        print("Error source file is not exist.")

# Hàm searchPath thực hiện tìm root của các file được lưu trong list headerName
# sau khi tìm thấy sẽ lưu vào list headerPath
# @param : None
# @return: None
def searchPath():
    if len(headerNameInc) > 0:
        for name in headerNameInc:
            for root, dirs, file in os.walk(path.abspath(pathIncludes)):
                if name in file:
                    if not isExist(headerFullPath, os.path.join(root, name)):
                        headerFullPath.append(os.path.join(root, name))
                    if not isExist(headerPath, root):
                        headerPath.append(root)

# Hàm searchCppFile thực hiện tìm file .cpp từ file header
# @param source: đường dẫn file header
# @return:  đường dẫn file source
def searchCppFile(header):
    file = Path(header).name
    direction = path.dirname(path.abspath(header))
    extension = [".cpp", ".c"]
    t_path = ""
    if file.find('.h') != -1:
        for ext in extension:
            filesource = file.replace('.h', ext)
            for root, dirs, files in os.walk(direction + '\\'):
                if filesource in files:
                    t_path = os.path.join(root, filesource)
    return t_path

def writeFile(filename, data):
    if path.exists(filename) :
        file = open(filename, "a")
        file.writelines(data)
        file.close()
    else:
        file = open(filename, "w")
        file.writelines(data)
        file.close()

def process(source):

    if path.exists(pathBackupInc):
        os.remove(pathBackupInc)
    if path.exists(pathBackupLib):
        os.remove(pathBackupLib)
    if path.exists(pathIncludeConf):
        os.remove(pathIncludeConf)
    if path.exists(pathHeaderConf):
        os.remove(pathHeaderConf)

    search(source)
    searchPath()

    for full in headerFullPath:
        search(full)
        pathsrc = searchCppFile(full)
        if pathsrc != "" :
            search(pathsrc)
    searchPath()

    for full in headerFullPath:
        if full.find( path.abspath(pathIncludesLib) ) != -1:
            headerFullPathLib.append(path.dirname(full))
        else:
            headerFullPathInc.append(searchCppFile(full))

    t_headerPath = []
    for full in headerPath:
        if full.find(path.abspath(pathIncludesLib)) == -1:
            t_headerPath.append(full)

    for header in headerFullPath:
        if header.find( path.abspath(pathIncludesLib) ) != -1:
            temp = searchCppFile(header) + ".o"
            temp = Path(temp).name
            temp = os.path.join(path.abspath(pathOutput), temp)
            writeFile(pathHeaderConf, temp + "\n")
        else :
            temp = searchCppFile(header) + ".a"
            writeFile(pathHeaderConf, temp + "\n")

    for headerInc in headerFullPathInc:
        writeFile(pathBackupInc, headerInc + "\n" )
    for headerLib in headerFullPathLib:
        writeFile(pathBackupLib, headerLib + "\n" )
    for head in t_headerPath:
        writeFile(pathIncludeConf, head + "\n" )
    print("Write configure done.")


if len(sys.argv) > 1:
    process(sys.argv[1])
else:
    print("Error no input source file.")