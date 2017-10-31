#!/bin/bash

# download pdc analysis
DIR=projects/brain-modelling/analysis/pdc-analysis/output/
#std-s03-10/samplesall/img/
DEST=/home/phil/

mkdir -p $DEST/$DIR

# to import from peanut
SRCDIR=/media/phil/p.eanut/projects/data-andrew-beta/output/
rsync -rvzt --progress --exclude='*.mat' $SRCDIR $DEST/$DIR
