#!/bin/bash

DATASETS=(
    #"2017-02-18-MCMTLOCCD_TWL2-T40-C113-P10-lambda=0.99-gamma=1.00-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-info-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122")

for DATASET in "${DATASETS[@]}"
do
    DATASETNAME="${DATASET/"-*"/}"
    echo "Working on $DATASETNAME"

    echo "Converting eps to pdf"
    find ./output -name "$DATASET.eps" -exec epstopdf {} \;

    echo "Merging pdf"
    # for debug
    find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output '$DATASETNAME'.pdf' "$0"
    #find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'pdftk "$@" cat output "$DATASETNAME".pdf' "$0"
done
