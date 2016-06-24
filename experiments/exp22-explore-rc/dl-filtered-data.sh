#!/bin/bash
# Download a tiny set of filtered files to laptop

DIR=projects/brain-modelling/analysis/lattice-svm/output/P022-9913/al-std/lf-MQRDLSL2-p10-l099-n400/

# declare an array variable
declare -a FILES=("trial1.mat" "trial2.mat" "trial3.mat")
FILE_LIST=trial-files.txt
echo "lattice-filtered-files.mat" > $FILE_LIST

# loop through the above array
for i in "${FILES[@]}"
do
   echo "$i" >> $FILE_LIST
   # or do whatever with individual element of the array
done

#cat $FILE_LIST

if [ ! -d "$DIR" ]; then
    mkdir -p ~/$DIR
fi

rsync -rvz --progress --files-from=$FILE_LIST chrapkpk@blade16:Documents/$DIR ~/$DIR


