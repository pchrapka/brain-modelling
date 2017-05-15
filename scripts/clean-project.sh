#!/bin/bash

cur_dir=$(pwd)
cd ..
find -type f -name 'progressbar*.txt' -delete
cd $cur_dir

