# GridWars

This repository holds the source code of GridWars, created originally by Mark Incitti in 2006. The goal of this project is to improve compatibility with embedded systems, such as the Respberry Pi.

## Build intructions

This game uses the [BlitzMax game engine](http://www.blitzbasic.com/Products/blitzmax.php), and is written in its BASIC-resembling language. As such, to compile the game, you will need the BMX compiler for your system. There are two main implementations, the [official one](https://github.com/blitz-research/blitzmax) and [BMX-NG](http://www.bmx-ng.com/main/), which has improved ARM and cross compilation support.

### Building on the Raspberry Pi

- Install the dependencies of the BMX-NG compiler: `sudo apt-get install libasound2-dev libpulse-dev libxft-dev libxxf86vm-dev`
- Get the BMX-NG compiler for RPi from here: https://github.com/bmx-ng/bmx-ng/releases
- Extract it to somewhere
- `cd` into the cloned game repository
- Build the game like this: `PATH=$SOMEWHERE/BlitzMax/bin:$PATH bmk makeapp -t gui -r -w gridwars.bmx`

### Cross compiling to Raspberry Pi

Unfortunately, the build system doesn't respect `CC` and `CXX`, and always calls the native compiler. You'll have to do some manual hacking.

- Make sure you have a C++ cross compiler installed (eg. `arm-linux-gnueabihf-g++`)
- Copy the OpenGL/GLES libraries from the Raspberry Pi to your system. You have to copy `/opt/vc/` from the Pi (or from a Pi disk image) to the same place on your native system. If this path is not good for you, you can change it in `BlitzMax/mod/sdl.mod/sdlgraphics.mod/sdlgraphics.bmx`
- Create a new directory that will hold symlinks to the cross compilers, eg. `armcc`, and enter into it
- `for f in /usr/bin/arm-linux-gnueabihf-*; do f2=$(basename $f); ln -s $f ./${f2/arm-linux-gnueabihf-/}; done`
- Install the dependencies of the BMX-NG compiler: `sudo apt-get install libasound2-dev libpulse-dev libxft-dev libxxf86vm-dev`
- Get the BMX-NG compiler for RPi from here: https://github.com/bmx-ng/bmx-ng/releases
- Extract it to somewhere
- `cd` into the cloned game repository
- Build the game like this: `PATH=$SOMEWHERE/armcc:$SOMEWHERE/BlitzMax/bin:$PATH bmk makeapp -t gui -l raspberrypi -g arm -r -w -v gridwars.bmx`
- At the very end, you will get a compile error about an unexpected `-m32` flag, or undefined EGL symbols. To fix it, copy the failing `g++` command, replace `g++` with `arm-linux-gnueabihf-g++`, remove `-m32` and also append `-lEGL` to the end
