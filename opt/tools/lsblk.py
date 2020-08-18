import json
import re
import os
import subprocess

# a quick script to parse lsblk with options to get model and serial
# information from lsblk without having to use smartctl (expensive)
# will integrate with lsdev script later

#run lsblk -a -n -r -o name,model,serial
try: 	
	lsblk_result = subprocess.Popen(
	["lsblk","-a","-n","-r","-o","name,model,serial"], 
	stdout=subprocess.PIPE,universal_newlines=True).stdout
except OSError:
	print("Error executing lsblk.")
	exit(1)
block_devices = {};
for line in lsblk_result:
	regex = re.search("^(sd[a-z]{1,2})\s+([^\s]+)\s+([^\s]+)$",line)
	if regex != None:
		block_devices[regex.group(1)] = (regex.group(2).replace("\\x20"," "),regex.group(3).replace("\\x20"," "));
print(json.dumps(block_devices, indent=4))		
