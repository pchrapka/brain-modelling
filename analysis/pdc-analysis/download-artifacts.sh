#!/bin/bash

# download pdc analysis
DIR=projects/brain-modelling/analysis/pdc-analysis/output/
#std-s03-10/samplesall/img/
DEST=/home/phil/
SRC=chrapkpk@blade16:Documents/

mkdir -p $DEST/$DIR
rsync -rvzt --progress --exclude='*.mat' $SRC/$DIR $DEST/$DIR
