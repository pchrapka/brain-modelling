#!/bin/bash

# download raw data
DIR=projects/brain-modelling/analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2/
DEST=/media/phil/p.eanut/
SRC=chrapkpk@blade16:Documents/

mkdir -p $DEST/$DIR
rsync -rvzt --progress --include='*.mat' --exclude='*' $SRC/$DIR $DEST/$DIR
