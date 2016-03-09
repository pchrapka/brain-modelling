#!/bin/bash
# Set up dependencies

## Install openmeeg
#sudo apt-get install openmeeg-tools

OS=$(uname -m)
echo "OS: $OS"
if [ "$OS" == "x86_64" ]
then
    DIR=linux64
    URL=http://openmeeg.gforge.inria.fr/download/OpenMEEG-2.2.0-Linux64.amd64-gcc-4.3.2-OpenMP-static.tar.gz
else
    echo "Unknown OS"
    exit 2
fi

PKGDIR=~/Documents/MATLAB/openmeeg/$DIR

FILE=openmeeg.tar.gz
sudo mkdir -p $PKGDIR
sudo wget -O $PKGDIR/$FILE $URL

CURDIR=$(pwd)
cd $PKGDIR
sudo tar --strip-components=1 -xzf $FILE
cd $CURDIR

echo "Add the following lines to your .bashrc file"
echo "    export PATH=\$PATH:$PKGDIR/bin"
echo "    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$PKGDIR/lib"

## Download data
# wget ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/Subject01.zip
