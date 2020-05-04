import serial.tools.list_ports

ports = serial.tools.list_ports.comports()

print("********")
for port, desc, hwid in sorted(ports):
    print("* " + port + " *")

print("********")