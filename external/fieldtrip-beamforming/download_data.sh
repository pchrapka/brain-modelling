#!/bin/bash

DESTDIR=anatomy
if [ ! -d "$DESTDIR" ]; then
    mkdir $DESTDIR
fi

TMPFILE=`mktemp`
#TESTFILE=http://www.colorado.edu/conflict/peace/download/peace.zip
DATAFILE=ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/Subject01.zip
wget $DATAFILE -O $TMPFILE
unzip -d $DESTDIR/Subject01 $TMPFILE
rm $TMPFILE
