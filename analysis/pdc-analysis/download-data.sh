#!/bin/bash

# download pdc analysis
DIR=analysis/pdc-analysis/output/
#std-s03-10/samplesall/img/
DEST=/home/phil/projects/brain-modelling/$DIR
mkdir -p $DEST

rsync -rvz --progress --exclude='*.mat' chrapkpk@blade16:Documents/projects/brain-modelling/$DIR $DEST
