from os import path
import os

folder="Arduino15"
pathRoot="C:\\Users"
pathPathFileConf="tools\\etc\\path.conf"


def writeFile(filename, data):
    if path.exists(filename) :
        file = open(filename, "a")
        file.writelines(data)
        file.close()
    else:
        file = open(filename, "w")
        file.writelines(data)
        file.close()


if path.exists(pathPathFileConf):
    os.remove(pathPathFileConf)

for root, dirs, file in os.walk(pathRoot) :
    if folder in dirs:
        writeFile(pathPathFileConf, path.join(root, folder))
        break