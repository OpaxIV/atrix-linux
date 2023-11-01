#!/bin/sh -e


# Basic Artix Install Script

# Changelog:
# 	30.10.2023: 


# 2do:
#	- add wlan support (currently only working with ethernet)


# References:
# This script has been created with the help of the following URLs:
#	- https://www.youtube.com/watch?v=FR3czoXpPoc
#	- https://github.com/Zaechus/artix-installer/blob/main/install.sh
#	- https://github.com/Zaechus/artix-installer/blob/main/src/installer.sh
#	- https://gitlab.com/FabseGP02/artix-install-script/-/blob/main/scripts/functions.sh?ref_type=heads
#	- https://github.com/classy-giraffe/easy-arch/blob/main/easy-arch.sh#L121


## Load Keymap (temporarly)

# search for available keyboard layouts (uncomment if needed)
#find /usr/share/kbd/keymaps/ -type f | less

# load wished keymap
loadkeys de_CH-latin1


## Choose Init System
# to add, might already be integrated in ISO




## Check Boot Mode

[ ! -d /sys/firmware/efi ] && printf ""


if [ ! -d /sys/firmware/efi ]; then
	printf "BIOS System detected"
	
else
	prinf "UEFI System detected"
	

## Install NetworkManager (on hold, can be ignored with ethernet)
#print "Installing and enabling NetworkManager."
pacstrap /mnt networkmanager >/dev/null

#systemctl enable NetworkManager --root=/mnt &>/dev/null

	
	
## Format Drive(s) and Create Partitions

# Choosing disk for the installation.
print "Available disks for the installation:"
PS3="Please select the number of the corresponding disk (e.g. 1): "				## check why PS3
select ENTRY in $(lsblk -dpnoNAME|grep -P "/dev/sd|nvme|vd");					## check what this does, for understanding, $-> variable?
do
    DISK="$ENTRY"																
    info_print "Artix Linux will be installed on the following disk: $DISK"
    break
done


## Set Password for the LUKS Container. --> saved into variable for later usage
print "Please set a password for the LUKS encrypted partition."

# read from the file descriptor, -s = disable echo, -r = disable backslashes
read -r -s password

# Check user input
if [[ -z "$password" ]]; then													## -z = true if empty string or an uninitialized variable
        echo
        error_print "No password input, please try again."
		
## fi?

print "Repeat password."
read -r -s password2

echo
if [[ "$password" != "$password2" ]]; then
	error_print "Passwords not matching, please try again."
