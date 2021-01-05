#!/usr/bin/env python3
#
# this program displays osd variables in yaml
# using a command line option, the user can choose what specific devices to exclude by the device alias or what drives to include by the type of drive (HDD, CAS, or SSD)
###################################################################################################################################################################################

import subprocess
import re
import os
import sys
from optparse import OptionParser

###################################################################################################################################################################################
#   get_path_variables()
# ARGS: none
# DESC: get the path variables needed for all other functions
###################################################################################################################################################################################
def get_path_variables():
    # get the alias config path, if it fails, assume /etc
    # get the device path, if it fails, assume /dev
    
    conf_path = os.getenv('ALIAS_CONFIG_PATH')
    if conf_path == None:
        log("No alias config path set in profile.d ... Defaulting to /etc")
        conf_path = "/etc"
    dev_path = os.getenv('ALIAS_DEVICE_PATH')
    if dev_path == None:   
        log("No device path set in profile.d ... Defaulting to /etc")
        dev_path = "/dev"
    
    return conf_path, dev_path
    
    
##################################################################################################################################################################################
#   getHba(hbas)
# ARGS: hbas ( a list of numbers which identify "plugged in" hba cards listed by the lspci command )
# DESC: get the number of HBA cards that are "plugged in". 
##################################################################################################################################################################################
def getHba(hbas):
    hbaCards = []
    allPcis = subprocess.Popen(["lspci"], universal_newlines = True, stdout = subprocess.PIPE).stdout
    for line in allPcis:                                    
        for card in hbas:
            regex = re.search("({c})".format(c = card), line)
            if regex != None:
                hbaCards.append(regex.group(0))
                
    return hbaCards
    
    
##################################################################################################################################################################################
#   getChassis(hbaCards)
# ARGS: hbaCards ( a list of hba cards found )
# DESC: get the size of the chassis, based on the quantity of HBA cards. This will work if the chassis is not a 
#   hybrid chassis, because it effectively multiplies the number of HBA cards by 15. Returns the chassis size.
#   takes the list of hba cards as an argument
##################################################################################################################################################################################
def getChassis(hbaCards):
    hbaQuantity = len(hbaCards)
    if hbaQuantity == 0:
        return "No Supported HBA Detected"
    else:
        switch = { 
        1: "15",
        2: "30",
        3: "45",
        4: "60"
        }
        if (hbaQuantity == 1 or hbaQuantity == 2 or hbaQuantity == 3 or hbaQuantity == 4):
            chassisSize = switch.get(hbaQuantity)
        else:
            chassisSize = "No Supported HBA Detected"
    return chassisSize
    
    
##################################################################################################################################################################################
#   hybridChassisCheck()
# ARGS: none
# DESC: Check if the machine has a hybrid chassis (has some 24i slots) or not. Returns a boolean which is True if there is a 24i slot and false otherwise
##################################################################################################################################################################################  
def hybridChassisCheck():
    a = None
    hybridChassis = 0
    
    a = subprocess.Popen(["/opt/tools/storcli64", "show", "all"], stdout = subprocess.PIPE, universal_newlines = True).stdout
    for line in a:
        b = re.search( "24i", line) 
        if b != None:
            hybridChassis += 1
    if hybridChassis > 0:
        return True
    else:
        return False
        
        
##################################################################################################################################################################################
#   checkCas()
# ARGS: none
# DESC: finds out if the machine is running open-cas-linux and returns a boolean which is True if open-cas-linux is being run and false otherwise
##################################################################################################################################################################################              
def checkCas():
    if subprocess.run(["rpm", "-q", "open-cas-linux"], stdout = subprocess.PIPE, universal_newlines = True).returncode == 0:
        if subprocess.run(["casadm", "-L"], stdout = subprocess.PIPE, universal_newlines = True).stdout == "No chaches running":
            CAS = False
        else:
            CAS = True
    else:
        CAS = False
        
    return CAS
    
    

##################################################################################################################################################################################
#   getBAYS(DEVICE_PATH)
# ARGS: DEVICE_PATH (a path variable needed in order to read the symbolic link of the alias
# DESC: gets the device name and the symbolic link that points to it. Returns a list containing tuples. Each tuple has a symbolic link and the device that it points to.
##################################################################################################################################################################################
def getBAYS(DEVICE_PATH, CONFIG_PATH):
    BAYS = []
    allBays=subprocess.Popen(["cat", CONFIG_PATH+"/vdev_id.conf"], stdout = subprocess.PIPE, universal_newlines = True).stdout
    for line in allBays:
        regex = re.search("^alias\s(\S+)\s", line)                                                              
        if regex != None:
            bay = regex.group(1)
            
            if subprocess.run(["ls", DEVICE_PATH+"/"+bay],stderr = subprocess.PIPE, stdout = subprocess.PIPE, universal_newlines = True).returncode == 0:
            # if there is a symbolic link in the specified path, check what device it points to. Append the symbolic link and the device to a list.
                symLinkDestination = subprocess.run(["readlink", DEVICE_PATH+"/"+bay], stdout=subprocess.PIPE, universal_newlines=True).stdout
                symLinkDestination = symLinkDestination.strip()
                BAYS.append((bay, symLinkDestination))
            else:
                BAYS.append((bay, None))
    return BAYS

    
##################################################################################################################################################################################
#   getEverythingToGetRidOf(driveTypes, badDrives, DEVICE_PATH, CAS)
# ARGS: driveTypes (a list containing strings for the -c, -s , -H options, list entries are empty if options aren't used)
#       badDrives  (a list of the arguments provided for the option -e if specified by the user, otherwise an empty list)
#       DEVICE_PATH ( the device path as returned by the getPathVariables function)
#       CAS (either true if the machine is running open-cas-linux or false otherwise)
# DESC: Generate a list of device names that are not wanted in the program output.
#       if the -s , -H option is used, run the lsdev command to find what drives are either HDD or SSD
#       if the -c option is used, run 
#       if the -e option is used, run the readlink command to find the device names for the aliases specified by the user
#       if there are no options used, add the drives used as caches to the list of unwanted drives
#       return a list of all the unwanted drives 
##################################################################################################################################################################################  
def getEverythingToGetRidOf(driveTypes, badDrives, DEVICE_PATH, CAS):
    caches = []
    cores = []
    coreTuples = []
    driveGivenTwice = False
    HDDs = []
    SSDs = []
    everythingToGetRidOf = []
    errMess = []
    CASDevices = []
    
    if CAS == True:
        # get lists of the core and cache device names. (Device name meaning the target of the symbolic link)
        casadmList = subprocess.Popen(["casadm", "-L", "-o", "csv"], stdout=subprocess.PIPE, universal_newlines=True).stdout
        for line in casadmList:
            cache = re.search("^cache,.*,/dev/([A-Za-z]+).*,.*$", line)
            if cache != None:
                caches.append(cache.group(1))
                
        casadmList = subprocess.Popen(["casadm", "-L", "-o", "csv"], stdout=subprocess.PIPE, universal_newlines=True).stdout
        for line in casadmList:
            core = re.search("^core,.*,/dev/([A-Za-z]+).*,.*,.*,/dev/(cas.*)$", line)
            if core != None:
                coreTuples.append((core.group(2), core.group(1)))
        cores = [drive[1] for drive in coreTuples]  
        CASDevices = cores+caches
    
    if len(driveTypes) != 0: 
        # find the device names (the symbolic link's target) for the devices that match the drive type specified on the command line and store them in lists
        
        if "HDD" in driveTypes:  
            pass
        else:
            lsdev = subprocess.Popen(["lsdev", "-tdn"], stdout=subprocess.PIPE, universal_newlines=True).stdout
            for line in lsdev:
                HDDs += re.findall("\d+-\d+\s+\(/dev/([a-z]+),HDD\)", line)         
    
        if "SSD" in driveTypes:
            pass
        else:
            lsdev = subprocess.Popen(["lsdev", "-tdn"], stdout=subprocess.PIPE, universal_newlines=True).stdout
            for line in lsdev:
                SSDs += re.findall("\d+-\d+\s+\(/dev/([a-z]+),SSD\)", line)          
        
        everythingToGetRidOf = HDDs+SSDs          # add all drives that the user doesn't want in the output to create a list of everythingToGetRidOf
        
        everythingToGetRidOf += CASDevices      # make sure no core or cache drives show up in the output when -c option is not used         
                
        if "CAS" in driveTypes and CAS == True:               #deal with the - c option : if -c option is used, take core drives out of everythingToGetRidOf
            for drive in everythingToGetRidOf:
                for core in cores:
                    if drive == core:
                        everythingToGetRidOf.remove(drive)
                        everythingToGetRidOf.insert(0, None)
            
    if len(badDrives) != 0: # deal with the -e option
        for badDrive in badDrives:
            if subprocess.run(["readlink", DEVICE_PATH+'/'+badDrive],stderr = subprocess.PIPE, stdout=subprocess.PIPE, universal_newlines=True).returncode == 0:
                badDevice=subprocess.run(["readlink", DEVICE_PATH+'/'+badDrive], stdout=subprocess.PIPE, universal_newlines=True).stdout
                badDevice=badDevice.strip() 
                if CAS:# get the device name as found from the Alias (symbolic link)
                    for stuff in coreTuples:
                        if stuff[1] == badDevice and stuff[0] in badDrives: # find out if the drive is listed in the -e option using both 'casX-X' and the alias from vdev_id.conf 
                            driveGivenTwice = True                          # don't put the drive that is specified using both 'casX-X' and the alias from vdev_id.conf in everythingToGetRidOf
                    if driveGivenTwice == False:                            # if the drive ends up in both lists, the program will try to remove it twice later which will crash the program
                        everythingToGetRidOf.append(badDevice)   
                    badDrives.remove(badDrive)
                    badDrives.insert(0, None)
                else:
                    everythingToGetRidOf.append(badDevice) 
                    badDrives.remove(badDrive)
                    badDrives.insert(0, None)
        while badDrives[badDrives.count(None)-1] == None:
            badDrives.pop(badDrives.count(None)-1)             # clean up the list by removing the None strings that were put in
            if len(badDrives) == 0:
                break  
                
    if CAS == True:            
        everythingToGetRidOf += caches
        
    for drive in everythingToGetRidOf:                   #deal with the same drive being in everythingToGetRidOf twice. remove duplicates in the list of everythingToGetRidOf
        possibleDuplicate=drive
        originalLength = len(everythingToGetRidOf)
        while possibleDuplicate in everythingToGetRidOf:
                everythingToGetRidOf.remove(possibleDuplicate)
        everythingToGetRidOf.insert(0, possibleDuplicate)
        while len(everythingToGetRidOf) != originalLength:
            everythingToGetRidOf.insert(0, None)
        if len(everythingToGetRidOf) != 0:
                while everythingToGetRidOf[everythingToGetRidOf.count(None)-1] == None:
                    everythingToGetRidOf.pop(everythingToGetRidOf.count(None)-1)
                    if len(everythingToGetRidOf) == 0:
                        break
         
    for drive in badDrives:                   #deal with the same 'casX-X' device being specified as an argument twice by the user. remove duplicates in the list of badDrives
        possibleDuplicate=drive
        originalLength = len(badDrives)
        while possibleDuplicate in badDrives:
                badDrives.remove(possibleDuplicate)
        badDrives.insert(0, possibleDuplicate)
        while len(badDrives) != originalLength:
            badDrives.insert(0, None)
        if len(badDrives) != 0:
                while badDrives[badDrives.count(None)-1] == None:
                    badDrives.pop(badDrives.count(None)-1)
                    if len(badDrives) == 0:
                        break
                            
    return everythingToGetRidOf
    
    
##################################################################################################################################################################################  
#   removeBadDrives(BAYS, everythingToGetRidOf, badDrives, CAS)
# ARGS: BAYS ( a list of the symbolic links and the devices that they point to, or in the case of a core for machines running open-cas-linux, the device name and the core name) 
#       everythingToGetRidOf ( a list of device names to not include in the output )
#       badDrives ( a list of aliases or 'casX-X' names that had no symbolic links so the device name doesn't exist or is unknown, respectively)
#       CAS (either true if the machine is running open-cas-linux or false otherwise)
# DESC: compare and remove everythingToGetRidOf and badDrives from BAYS. if there are remaining items in badDrives that were not in BAYS after all items have been compared
#       then those devices are not listed by casadm -L or vdev_id.conf commands and the program exits with the names of those drives
##################################################################################################################################################################################    
def removeBadDrives(BAYS, everythingToGetRidOf, badDrives, CAS):
    errMess = []
    cores = []
    if CAS:
        casadmList = subprocess.Popen(["casadm", "-L", "-o", "csv"], stdout=subprocess.PIPE, universal_newlines=True).stdout
        for line in casadmList:
                core = re.search("^core,.*,/dev/([A-Za-z]+).*,.*,.*,/dev/(cas.*)$", line)
                if core != None :
                    cores.append((core.group(2), core.group(1))) #get the 'casX-X' names for the core drives so the user input 'casX-X' names can be confirmed  
      
        for BAY in BAYS:
            for core in cores:                                                   
                    if core[1] == BAY[1]:
                        BAYS.insert(BAYS.index(BAY), (core[0], BAY[1])) #change the names of the cores to the "casX-X" format
                        BAYS.remove(BAY)
                        
    for BAY in BAYS:                
        
        for deviceName in everythingToGetRidOf:
            if deviceName == BAY[1]: 
                BAYS.remove(BAY)                   #remove items from BAYS that are also in everythingToGetRidOf
                BAYS.insert(0, None)
               
        for drive in badDrives:
            if drive == BAY[0]:  #deal with drives that are excluded by the user using the -e option but had no symbolic links
                BAYS.remove(BAY)        # BAY will never already have been removed from BAYS in the previous loop beacuse the lists badDrives and everythingToGetRidOf have no elements in common
                BAYS.insert(0, None)
                badDrives.remove(drive)
                badDrives.insert(0, None)
            
    if len(badDrives) != 0:
        while badDrives[badDrives.count(None)-1] == None:
            badDrives.pop((badDrives.count(None)-1))
            if len(badDrives) == 0:
                break
                        
    if len(badDrives) != 0:            # if there is anything left in the list of badDrives that couldn't be used, it must have been typed in wrong, and we should get rid of it
        for badDrive in badDrives:
                errMess.append(badDrive)      # tell the user what drives weren't able to be used
        sys.exit("invalid argument(s) to the -e option: {es}".format( es = errMess))
        
    for BAY in BAYS: 
        if BAY != None:
            if BAY[1] == None:                #clean up the lists to get rid of any None strings
                BAYS.remove(BAY)                   
                BAYS.insert(0, None)
                
    if len(BAYS) != 0:
        while BAYS[BAYS.count(None)-1] == None:
            BAYS.pop((BAYS.count(None)-1))
            if len(BAYS) == 0:
                break
    return BAYS
                                            
             
##################################################################################################################################################################################
#   displayVars(hbaCards, chassisSize, hybridChassis, BAYS, DEVICE_PATH)
# ARGS: hbaCards (the list of HBA cards that are used on the machine)
#    chassisSize (the size of the machine's chassis)
#    hybridChassis (a boolean which is true if the machine has a hybrid chassis and false otherwise
#    BAYS (the list of the bays that have a drive in them. The user can specify drives to exclude by alias name and which ones to include by media type)
#    DEVICE_PATH (a path variable returned by the get_path_variables function)
#    DESC: Displays the variables that have been grouped by all other functions in yaml format
##################################################################################################################################################################################
def displayVars(hbaCards, chassisSize, hybridChassis, BAYS, DEVICE_PATH):
    print("---")
    print("chassis_size: {chassis}".format(chassis = chassisSize))
    print("hybrid_chassis: {hchassis}".format(hchassis = hybridChassis))
    print("osd_auto_discovery: false")
    print("lvm_volumes:")
    for SLandDEV in BAYS:
        print(" - data: {DP}/{ALIAS}".format(DP = DEVICE_PATH, ALIAS = SLandDEV[0]))
    print('\n')
   

##################################################################################################################################################################################
#       main()
##################################################################################################################################################################################        
def main():
    #parse the command line for options and arguments. the only option is the -e one right now. the argument is a string of drives to exclude in the listing.
    badDrives = []  
    driveTypes = []
    parser = OptionParser()
    parser.add_option("-e", "--exclude-by-drive-alias",action="store", type=str, dest="drive_alias", nargs=1, default=None, help="-e: only show the drives that have not been  listed as arguments")
    parser.add_option("-c", "--include-all-cas devices", action="store_true", dest="CAS", default=False, help="-c: show the CAS drives, and drives from other options")
    parser.add_option("-s", "--include-all-SSDs",action="store_true", dest="SSD", default=False, help="-s: show the SSD drives, and drives from other options")
    parser.add_option("-H", "--include-all-HDDs",action="store_true", dest="HDD", default=False, help="-h: show the HDD drives, and drives from other options")
    (options, args) = parser.parse_args()
    if options.drive_alias != None:
        badDrives = options.drive_alias.split()
        # if there are bad arguments, they are found as the program runs by getting rid of all the good arguments from the badDrives list whenever they are used. If there are any arguments left then we know that they didn't match anything on the server.
    if options.SSD == True: 
        driveTypes.append("SSD")
    if options.HDD == True:
        driveTypes.append("HDD")
    if options.CAS == True:
        driveTypes.append("CAS")

    hbas = [ "3224", "3316", "3616", "3008"] #hard coded numbers used to identify HBA cards
    
    CONFIG_PATH, DEVICE_PATH = get_path_variables()
    hbaCards = getHba(hbas)
    chassisSize = getChassis(hbaCards)
    hybridChassis = hybridChassisCheck()
    CAS = checkCas()
    BAYS = getBAYS(DEVICE_PATH, CONFIG_PATH)
    everythingToGetRidOf = getEverythingToGetRidOf(driveTypes, badDrives, DEVICE_PATH, CAS)
    removeBadDrives(BAYS, everythingToGetRidOf, badDrives, CAS)
    displayVars(hbaCards, chassisSize, hybridChassis, BAYS, DEVICE_PATH)
  
if __name__ == "__main__":
    main() 