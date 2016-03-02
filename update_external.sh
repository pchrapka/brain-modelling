#!/bin/bash

DESTDIR=external/fieldtrip-beamforming
TMPDIR=`mktemp -d`
CURDIR=$(pwd)
FULLPATH=$CURDIR/$DESTDIR
if [ -d "$DESTDIR" ]; then
    # clean out old dirs, leave anatomy untouched
    cd $DESTDIR
    find . -not -path "./anatomy*" -not -path "." -type d -exec rm -rf {} +
    #find . -not -path "./anatomy*" -not -path "." -type d
    cd $CURDIR
fi
# clone updated into tmpdir
git clone --depth=1 --branch=master https://github.com/pchrapka/fieldtrip-beamforming.git $TMPDIR

if [ ! -d "$DESTDIR" ]; then
    mkdir $DESTDIR
fi
cd $TMPDIR
cp -r . "$FULLPATH"
#find . -not -path "./.git*" -not -path "." -exec cp -r {} "$CURDIR/$DESTDIR" \;
cd $CURDIR

# remove .git
rm -rf $DESTDIR/.git
# remove tmp folder
rm -rf $TMPDIR
