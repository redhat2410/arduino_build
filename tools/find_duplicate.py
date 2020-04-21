import os
from os import path
import sys

def duplicate(conf, data):
    if path.exists(conf):
        file = open(conf, "r", encoding='utf-8')
        isFind = False
        for line in file:
            if line.find(data) != -1:
                isFind = True
                break
            isFind = False
        
        if not isFind:
            writeFile(conf, data)
    else:
        print("Error configure file is not exist.")


def writeFile(filename, data):
    if path.exists(filename):
        file = open(filename, "a")
        file.writelines(data)
        file.close()
    else:
        file = open(filename, "w")
        file.writelines(data)
        file.close()