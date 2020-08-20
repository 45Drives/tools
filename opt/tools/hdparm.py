# hdparm.py
# parses hdparm output to return model
import re
import subprocess


def get_model_serial_firmware(device_name):
	model="unknown"
	serial="unknown"
	firmware="unknown"
	try:
		hdparm_result = subprocess.Popen(
			["hdparm","-I", device_name],
			stdout=subprocess.PIPE,universal_newlines=True
		).stdout
	except OSError:
		print("Error executing hdparm. Is it installed?")
		exit(1)
	for line in hdparm_result:
		regex_model = re.search("^\s+Model Number:\s+(.*)$",line)
		regex_serial = re.search("^\s+Serial Number:\s+(.*)$",line)
		regex_firmware = re.search("^\s+Firmware Revision:\s+(.*)$",line)
		if regex_model != None:
			 model=regex_model.group(1).rstrip()
		if regex_serial != None:
			serial=regex_serial.group(1).rstrip()
		if regex_firmware != None:
			firmware=regex_firmware.group(1).rstrip()
			break
	return (model,serial,firmware)


device = "/dev/sda"
msf = get_model_serial_firmware(device)
print(msf)
