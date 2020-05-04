from cx_Freeze import setup, Executable

base = None

executables = [Executable("listPort.py", base=base)]

packages = ["idna"]

options = {
    'build_exe':{
        'packages':packages,
    },
}

setup(name="listPort",options=options, version="1.0", description='none',executables=executables)