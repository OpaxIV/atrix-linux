## Artix Linux Install Guide

These instructions are made for an "Almost-Full" disk encryption, faster boot time.
The /boot partition will be unencrypted.

## Before you begin
Make sure to download the correct ISO. Even the "base" ISOs have different versions (e.g. init systems).
This guide is concipated for the "runit" init system.

### Resources

- Install Artix or Arch Linux (Encrypted system) - https://odysee.com/@Luke:7/install-artix-or-arch-linux-(encrypted:2
- After a Minimal Linux Install: Graphical Envionment and Users - https://www.youtube.com/watch?v=nSHOb8YU9Gw
- Artix Linux Full Install with runit - https://www.youtube.com/watch?v=mIpZA6z-Ctk
- Installation With Full Disk Encryption - https://wiki.artixlinux.org/Main/InstallationWithFullDiskEncryption
- Wiki Main Installation - https://wiki.artixlinux.org/Main/Installation

### initial login
username: **root**
password: **artix**


### Change Keyboard Layout (temporarly):

`find /usr/share/kbd/keymaps/ -type f | less`

Find the wished layout and set it like the following:
(Swissgerman: ./i386/qwertz/de_CH-latin1)

`loadkeys de_CH-latin1`

Note: It is also possible to do it from the initial splash screen when booting from the ISO:

<img src=":/6fae165cb01b464f8757c28f520b59b1" width="700">

### Check for UEFI or BIOS

`ls /sys/firmware/efi/efivars`

If you have BIOS (hence not UEFI), then the output should be:
`ls: cannot access '/sys/firmware/efi/efivars: No such file or directory'`


### Formatting Drives and Partitions

Get name of drive you want to format:

`lsblk`

Afterwards run fdisk with the specified disk:
(replace X with the corresponding letter)

`fdisk /dev/sdX`

*BOOT PARTITION*

In fdisk, input the following commands:

`d` - delete partition (input multiple times if >1 partitions are present on drive)

`n` - add new partition

Hit ENTER for `primary` (default) and again ENTER for `Partition Number` default 1.
Hit ENTER for `First sector (... default 2028)`.

For `Last Sector...` input `+1GB` at the end. This will be our /boot partition.

*ENCRYPTED PARTITION*

When still being in fdisk /dev/sdX, input the following:

`n` - add new partition

And hit ENTER until you arrive at the end. All default settings are fine for this type of partition.


Finally input `w` to write the changes.

Check if correct:

`lsblk`

```
...
sda
	sda1
	sda2
...
```

### File Systems and getting the Partitions ready

*BOOT PARTITION*

UEFI needs a /boot partition in FAT File System Format. It is not necessary for BIOS but having it by default makes copying the install from BIOS to UEFI machines easier.

run:

(replace X with letter and Y with number of partition)

`mkfs.fat -F32 /dev/sdXY`

*ENCRYPTED PARTITION*

For better security, randomize the contents on drive before starting to create the file system:

Note: It will take a long time.

`dd if=dev/urandom of=/dev/sdXY`

Afterwards, continue with the following:

`cryptsetup luksFormat /dev/sdXY`

Enter `YES` and a password for the partition.

If everything is fine, you should return to the shell.

We need to do further adjustements, so input the following:

`cryptsetup open /dev/sdXY "*any name you want for the partition*"`

to decrypt the drive.

Run `lsblk`, check if you can see the named partition under sdXY.
```
sda
	sda1
	sda2
		"*the name you gave*"
```

Now we can finally create a file system for our home partition:

`mkfs.btrfs /dev/mapper/"*the name you gave*"`


Mount the partition:
``mount /dev/mapper/"*the name you gave*" /mnt`

### Create and Mount Directories

*ENCRYPTED PARTITION*

`mkdir /mnt/boot`

Check with `ls /mnt`

If you see your /boot then you are good to go.

`mount /dev/sdXY /mnt/boot`, replace XY with the letter and number of the BOOT PARTITION.

Run `lsblk` and it should look like this:

```
NAME		...			MOUNTPOINTS
...
sda
	sda1				/mnt/boot
	sda2
		part			/mnt
...
```

### Choosing Mirrors for Speed (optional)

Open the mirrorlist with:

`vi /etc/pacman.d/mirrorlist`

Place locations near you further on the top of the script under `# Default Mirrors`

E.g.

```
...
# Switzerland
Server = ...
...
```
Take the whole line `Server = ...` and place it under `# Default Mirrors`.


Make sure that you are connected to the internet for the upcoming tasks.

- ETHERNET - Easier, access will be found automatically
-  WLAN - ... // WRITE INSTRUCTIONS FOR IT

Check with `ping "*name of website*"` if you have internet access.

### Install OS and Programs

`basestrap -i /mnt base base-devel runit elogind-runit linux linux-firmware grub networkmanager networkmanager-runit cryptsetup lvm2 lvm2-runit vim man-db`

The following programs are going to be installed with the above command:
- `base` - basic system tools
- `base-devel`- used for compilation of packages
- `runit` - init System
- `elogind-runit` - used by the runit init system // check what this is --> systemd?
- `linux` - kernel
- `linux-firmware` - used for proprietary components in the machine // check what this is
- `grub` - bootmanager
- `networkmanager` - used to connect to internet
- `networkmanager-runit` - used by init system to run network related settings
- `cryptsetup` - for encrypting and decrypting drive
- `lvm` - for encrypting and decrypting drive
- `lvm2-runit` - for encrypting and decrypting drive, loaded by init system
- `vim`- text editor
- `man-db` -  installs the manpages
- (`neovim` - NeoVim is an enhanced upgrade to Vim that incorporates more features)
- (efibootmgr - only needed if UEFI)

NOTE: Other init systems can be installed instead. Check the artix main wiki for further information:
E.g. for openrc:
`basestrap /mnt base base-devel openrc elogind-openrc`

### Chrooting into the freshly installed OS

Change into the OS:

`artix-chroot /mnt bash`

REMINDER: If you forgot any necessary software, run

`payman -S "*name of the software*"`

to install what you need.

E.g. install `man` by running
`pacman -S man-db`

Note: you may need to install `sudo` if not already done

### Setting Timezone, Localization, Hostname

*TIMEZONE*
`ln -s(f) /usr/share/zoneinfo/Europe/Switzerland /etc/localtime`

//artix linux states the f parameter, to check why

Check if it worked with `ls -l /etc/localtime`

`$... /etc/localtime -> /usr/share/zoneinfo/Europe/Switzerland`

Lastly sync the hardware clock with
`hwclock --systohc`

*LOCALIZATION*
Set the language and encoding of the prefered language.
NOTE: This has nothing to do with the keyboard layout.

`vim /etc/locale.gen`

Uncomment the two lines containing the wished language.

Generate your desired locales running:
`locale-gen`

To set the locale systemwide, create or edit `/etc/locale.conf` and add the following lines:
```
export LANG="en_US.UTF-8"     <-- localize in your languages
export LC_COLLATE="C"
```

*HOSTNAME*

Set the name of the machine:
`echo "*name of machine*" > /etc/hostname`

Check:
`cat /etc/hostname`

### Enable the NetworkManager for wifi/internet
Configure the following (used for routing of your IP-Adresses):
`vim etc/hosts`

Add the following to the file:
NOTE: Replace hostname with your actual hostname.
```
127.0.0.1		localhost
::1				localhost
127.0.1.1		*hostname*.localdomain *hostname*
```

Furthermore, run the following:
`ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/current`

### Users and Passwords

First, set the root passwd:
`passwd`

Second, create a regular user and password:
NOTE: replace user with the wished username

NOTE2: You should add users to the wheel group if they need to use the su command to become root.
`useradd -G wheel -m "name of your user"`
`passwd "name of your user"`

And edit the /etc/sudoers file to allow users to run commands with the `sudo` prefix:
run
`# EDITOR=vim visudo`
to edit the visudo file with the defined editor for the duration of the current shell session. 

At the end, uncomment the following line
`%wheel      ALL=(ALL:ALL) ALL`

*Reference:* https://wiki.archlinux.org/title/sudo
<br />

*OPTIONAL: DISABLE DUPLICATE LOGIN*
If you want to avoid having to input two passwords (one for the drive and one for the user) each time you log in, do the following:
`vim /etc/runit/sv/agetty-tty1/conf`

NOTE: replace user with the wished username
Under `GETTY_ARGS="--noclear"` add `--autologin user` as a flag right after.

### Preparing Decryption on boot
Run
`vim /etc/mkinitcpio.conf`

At the end of the paragraph about HOOKS there is the following line:
`HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)`

Add the following:
`HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)`

NOTE: Make sure you have lvm2 installed!

Build the image:
`mkinitcpio -p linux`

### Pre Grub configuration with UUIDs to decrypt

If you are still on localhost
`[localhost/]#`

`exit` (or CTRL + D) to be back onto the main drive.
`localhost:[root]:~#`

Run the following to show the UUIDs of the partitions:
`lsblk -f`

Take the output of the command and output it into the /grub directory:
`lsblk -f >> /mnt/etc/default/grub`

Fstab is used by linux to know where the OS should mount the drives. //CHECK DEF.
Save the output to the following directory:
`fstabgen -U /mnt >> /mnt/etc/fstab`

Go back into the installation
`artix-chroot /mnt bash`

NOTE: The following commands are to be executed in the installation space until further notice.

`vim /etc/default/grub`

Look at the glichty mess at the end of the file.
Delete everything except for the information about the encrypted /home directory of the install.

```
		sdXY		crypto_LUKS 2			UUID_NUMBER			SIZE		...
			part	btrfs					UUID_NUMBER			SIZE		...
```

Cut and paste them right after `GRUB_CMDLINE_LINUX=""` and comment them out. They are only kept for reference.

Look at the top of file at the line `GRUB_CMDLINE_LINUX_DEFAULT="..."` and add the following:
NOTE: Replace `uuid of the encrypted partition` and `uuid of the decrypted partition`.
NOTE2: `cryptlvm` can be replaced with another name, since it is just the destinations mount point.

`GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet cryptdevice=UUID=uuid of the encrypted partition:cryptlvm root=UUID=uuid of the decrypted partition ioem=relaxed"` // CHECK WHAT IOEM=RELAXED DOES, not needed for this install, libreboot?

### Install GRUB and Configure
NOTE: Replace X with corresponding letter of the install.

For Legacy BIOS:
`grub-install /dev/sdX`

For UEFI:
`grub-install --target x84_64-efi --efi-directory=/boot/efi --bootloader-id=grub`


Run
`grub-mkconfig -o /boot/grub/grub.cfg`

to create the boot file for grub.

Check with `vim /boot/grub/grub.cfg` if the UUIDs where added to the file.

### Finishing up

CTRL + D out of the install and `reboot`.


### Installing a Graphical UI
*XORG*

`pacman -S xorg-server xorg xinit` // from luke smith instead of installing everything!


*DESKTOP *
Install your favorite desktop environment, for example XFCE4:
```
 pacman -S xfce4 xfce4-goodies
```

*FONTS*
`pacman -S ttf-linux-libertime ttf-inconsolata`

`pacman -S noto-fonts`


### Display Login Manager
Each DM has its own openrc package, which brings openrc's DM setup in line with runit and s6 counterparts. Currently we support XDM, LightDM, GDM, SDDM and LXDM.

*LightDM:*
![f164b310ad4ee15ea87c788b04e78568.png](:/bb83f162dc5f4805b4b195ae2686b20d)

Run the following command for the installation:
`pacman -S lightdm lightdm-runit`
`pacman -S lightdm lightdm-gtk-greeter` // from lukes video maybe only needed when using WM?



*RUNIT SOFTLINKS*
To run the services automatically on each boot, a softlink per service has to be instanced.

Note: the following command adds the services to start on boot AND starts them at the same time.

`ln -s /etc/runit/sv/"name of service /run/runit/service/"name of service"` // may also work if /run/runit/service is written, need to check

- lightdm
- NetworkManager
- dbus??




// the guide is not done, check

https://wiki.artixlinux.org/Main/Runit

NetworkManager and Display Login Manager need to be added as automatic services

// Network Manager `nmtui` ???


// graphics driver: https://wiki.archlinux.org/title/xorg // if older than 2010 you need specific drivers
//

`pacman -S`


### troubleshooting notes:

may need `dbus` for networkmanager AND lightdm, logind:
Service dependencies
Some services may depend on other services. For example, NetworkManager depends on dbus. To ensure that required dependencies are satisfied, check the service's run file. For example, for NetworkManager:

```
 # /etc/runit/sv/NetworkManager/run
 sv check dbus >/dev/null || exit 1
 ```
This means you have to enable dbus for NetworkManager to start
