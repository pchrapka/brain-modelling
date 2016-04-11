#!/bin/bash

TOPDIR=$HOME
DIR=projects/brain-modelling/experiments/output-common/fb/
DATADIRS=(MRIstd MRIstd-HMstd-cm MRIstd-HMstd-cm-EP022-9913)
all_dirs=()
for dir in ${DATADIRS[@]}; do
    all_dirs+=("$DIR$dir/")
done
#echo $DIR
#echo ${DATADIRS[@]}
#echo ${all_dirs[@]}

# upload preprocessed data
CURDIR=$(pwd)
cd $TOPDIR
rsync -rvz --relative --progress ${all_dirs[@]} chrapkpk@blade16:Documents/
# NOTE --relative arg creates child directories but you have to be in the top folder and match it up with the top in the destination tree
cd $CURDIR
