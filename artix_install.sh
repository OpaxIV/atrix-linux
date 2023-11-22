#!/bin/sh -e


# Basic Artix Install Script

# Changelog:
# 	30.10.2023: 


# 2do:
#	- add wlan support (currently only working with ethernet)
#	- choose init system (might only work on arch, not artix)
#	- choose kernel to install (might only work on arch, not artix)
#	- think about initial procedure to run this script (curl..), add instructions


# References:
#	- https://www.youtube.com/watch?v=FR3czoXpPoc
#	- https://github.com/Zaechus/artix-installer/blob/main/install.sh
#	- https://github.com/Zaechus/artix-installer/blob/main/src/installer.sh
#	- https://gitlab.com/FabseGP02/artix-install-script/-/blob/main/scripts/functions.sh?ref_type=heads
#	- https://github.com/classy-giraffe/easy-arch/blob/main/easy-arch.sh#L121
#	- https://unix.stackexchange.com/questions/466599/how-to-re-run-the-case-statement-if-the-input-is-invalid


## Load Keymap (temporarly)

# search for available keyboard layouts (uncomment if needed)
#find /usr/share/kbd/keymaps/ -type f | less

# load wished keymap
loadkeys de_CH-latin1


## Choose Init System
# to add, might already be integrated in ISO




### Check Boot Mode ###

if [ ! -d /sys/firmware/efi ]; then
	SYSTEM = "BIOS"
else
	SYSTEM = "UEFI"
fi	
printf "%s System detected\n" "$SYSTEM"				## print system variable, needs to be rechecked







### Install NetworkManager (on hold, can be ignored with ethernet)###
#print "Installing and enabling NetworkManager."
#pacstrap /mnt networkmanager >/dev/null

#systemctl enable NetworkManager --root=/mnt &>/dev/null













### Setting Passwords for User and LUKS Container ###

## Set Password for User Account
print "Please set a password for the User Account."

# read from the file descriptor, -s = disable echo, -r = disable backslashes
read -r -s userpassword

# Check user input
if [[ -z "$userpassword" ]]; then													## -z = true if empty string or an uninitialized variable
        echo
        error_print "No user password input, please try again."
		
fi

print "Repeat password."
read -r -s userpassword2

echo
if [[ "$userpassword" != "$userpassword2" ]]; then
	error_print "User Passwords not matching, please try again."
fi





## Set Password for the LUKS Container. --> saved into variable for later usage
print "Please set a password for the LUKS encrypted partition."

# read from the file descriptor, -s = disable echo, -r = disable backslashes
read -r -s lukspassword

# Check user input
if [[ -z "$lukspassword" ]]; then													## -z = true if empty string or an uninitialized variable
        echo
        error_print "No luks password input, please try again."
		
fi

print "Repeat password."
read -r -s lukspassword2

echo
if [[ "$lukspassword" != "$lukspassword2" ]]; then
	error_print "Passwords not matching, please try again."
fi





### Format Drive(s) and Create Partitions ###

# Choosing disk for the installation.
lsblk 										## print avaiable drives






## Partitioning

# Create Boot Partition (BIOS for now, UEFI in later step)
# Format as FAT32





# Create Encrypted LUKS Home Partition
# Format as LUKS



## Mount the Partitions
