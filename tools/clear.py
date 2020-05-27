import shutil
import os
from os import path

_pathOut = "output\\"
_pathLibraries = "libraries\\"
_pathCore = "core\\"
_pathInc = "inc\\"
_pathLib = "inc\\lib\\"

_pathETC = "tools\\etc\\"
_pathFormat = "_temp.conf"

if path.exists(_pathCore):
    print("Remove folder " + path.abspath(_pathCore))
    shutil.rmtree(_pathCore)
if path.exists(_pathLibraries):
    print("Remove folder " + path.abspath(_pathLibraries))
    shutil.rmtree(_pathLibraries)
if path.exists(_pathOut):
    print("Remove folder " + path.abspath(_pathOut))
    shutil.rmtree(_pathOut)
    
if len(os.listdir(path.abspath(_pathLib))) == 0:
    print("Remove folder " + path.abspath(_pathLib))
    shutil.rmtree(_pathLib)

if len(os.listdir(path.abspath(_pathInc))) == 0:
    print("Remove folder " + path.abspath(_pathInc))
    shutil.rmtree(_pathInc)

for root, dirs, files in os.walk(path.abspath(_pathETC)):
    for file in files:
        if file == _pathFormat:
            continue
        pathFile = path.join(root, file)
        print( "Remove " + pathFile )
        os.remove(pathFile)
