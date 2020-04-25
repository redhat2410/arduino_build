from os import path
from pathlib import Path
import os
import sys


pathBackupInc= "tools\\etc\\backupInc.conf"
pathBackupLib= "tools\\etc\\backupLib.conf"
pathIncludeConf="tools\\etc\\includes.conf"
pathHeaderConf="tools\\etc\\header.conf"
pathPathFileConf="tools\\etc\\path.conf"
pathTempConf="tools\\etc\\temp.conf"

pathIncludes = "inc\\"
pathIncludesLib = "inc\\lib\\"
pathOutput = "output\\"
pathLibrary = "C:\\Users\\admin\\AppData\\Local\\Arduino15\\packages\\esp8266\\hardware\\esp8266\\2.4.0\\libraries"

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
                if (result[0] != word_1) and (result[0] != word_7) :
                    if not isExist(headerNameInc, result[0]):
                        headerNameInc.append(result[0])
        file.close()
    else:
        print("Error source file is not exist.")

# Hàm searchPath thực hiện tìm root của các file được lưu trong list headerName
# sau khi tìm thấy sẽ lưu vào list headerPath
# @param : None
# @return: None
def searchPath():
    pathLibrary = []
    if path.exists(pathPathFileConf):
        file = open(pathPathFileConf, "r", encoding='utf-8')
        for line in file:
            t_str = line.split('\n')
            if t_str[0].find('"') != -1:
                t_str = t_str[0].replace('"','')
                pathLibrary.append(t_str)
            else:
                pathLibrary.append(t_str[0])
        file.close()
    else:
        print("Error configure file is not exist.")
        return 

    if len(headerNameInc) > 0:
        for pathlib in pathLibrary:
            for name in headerNameInc:
                for root, dirs, file in os.walk(path.abspath(pathlib)):
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
    if path.exists(pathTempConf):
        os.remove(pathTempConf)

    search(source)
    searchPath()

    for full in headerFullPath:
        search(full)
        pathsrc = searchCppFile(full)
        if pathsrc != "" :
            search(pathsrc)
    searchPath()

    for full in headerFullPath:
        if (full.find( path.abspath(pathIncludesLib) ) != -1) or ( full.find(pathLibrary) != -1 ):
            if not isExist(headerFullPathLib, path.dirname(full)):
                headerFullPathLib.append(path.dirname(full))
        else:
            if not isExist(headerFullPathInc, searchCppFile(full)):
                headerFullPathInc.append(searchCppFile(full))

    t_headerPath = []
    for full in headerPath:
        if (full.find(path.abspath(pathIncludesLib)) == -1) and ( full.find(pathLibrary) == -1 ):
            if not isExist(t_headerPath, full):
                t_headerPath.append(full)

    tempPath = []
    for full in headerPath:
        if full.find(pathLibrary) != -1:
            tempPath.append(full)

    for header in headerFullPath:
        if (header.find( path.abspath(pathIncludesLib) ) != -1) or (header.find(pathLibrary) != -1):
            temp = searchCppFile(header)
            if temp != "":
                temp = temp + ".o"
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
    for temp in tempPath:
        writeFile(pathTempConf, temp + "\n" )

    print("Write configure done.")


if len(sys.argv) > 1:
    process(sys.argv[1])
else:
    print("Error no input source file.")