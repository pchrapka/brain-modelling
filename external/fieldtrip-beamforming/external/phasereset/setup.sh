#!/bin/sh
# Setup phasereset

## Set up vars
CUR_DIR=$pwd
MATLAB_DIR=~/Documents/MATLAB

# Switch to the matlab dir to avoid issues
cd $MATLAB_DIR

## phasereset
PKG_NAME="Phase reset"
PKG_DIR=phasereset
# Check if the dir exists
if [ ! -d "$PKG_DIR" ]; then
    FILE=phasereset.tar.gz
    # Check if the zip file exists
    if [ ! -f "$FILE" ]; then
	# Download pkg
	echo "Downloading $PKG_NAME"
	wget https://github.com/pchrapka/phasereset/tarball/master
	mv master $FILE
    fi
    mkdir $PKG_DIR
    # Untar the file
    tar -C $PKG_DIR -xzf $FILE
    # Save subfolder to be removed
    RM_DIR=$(find $PKG_DIR -mindepth 1 -maxdepth 1 -type d)
    # Move contents up a level
    find $PKG_DIR -mindepth 2 -maxdepth 2 -exec mv -t $PKG_DIR \{\} +
    rm -rf $RM_DIR

    # Print confirmation
    echo "***************"
    echo "$PKG_NAME ready"
    echo "***************"
else
    # Print confirmation
    echo "***************"
    echo "$PKG_NAME already exists"
    echo "***************"
fi

echo
echo "If everything went well $PKG_NAME should work"

cd $CUR_DIR

