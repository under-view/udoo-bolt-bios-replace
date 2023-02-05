# UDOO Bolt Coreboot SeaBIOS

**NOTE:** At the moment flashing unsuccessful 

Script used to build coreboot + seabios payload to replace udoo-bolt's BIOS firmware

### Building Coreboot

```sh
# For a Debian-based system
$ sudo apt install git build-essential gnat flex bison libncurses5-dev wget zlib1g-dev

# For an Arch-based system
$ sudo pacman -S base-devel gcc-ada flex bison ncurses wget zlib git

# Builds coreboot for AMD zen processor
# When in menuconfig BE SURE TO SAVE UPDATED CONFIG
$ ./build.sh
```

### Flashing BIOS

On target machine

```
# Be sure linux headers + gcc is installed
$ ./build --flash-util coreboot/build/coreboot.rom
```
