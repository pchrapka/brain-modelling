#!/bin/bash

DATASET="2017-02-18-MCMTLOCCD_TWL2-T40-C113-P10-lambda=0.99-gamma=1.00-pdc-dynamic-seed-*-0.0073-0.0122"
DATASETNAME="2017-02-18-MCMTLOCCD_TWL2-T40-C113-P10-lambda=0.99-gamma=1.00-pdc-dynamic-seed-0.0073-0.0122"
echo "Converting eps to pdf"
find ./output -name "$DATASET.eps" -exec epstopdf {} \;

echo "Merging pdf"
find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output $DATASETNAME.pdf' "$0"
