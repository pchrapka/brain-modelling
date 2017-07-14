#!/bin/bash

# # Test
# DIR=output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-for-filter
# NAME=2017-04-14-MCMTLOCCD_TWL4-T20-C12-P11-lambda0.9900-gamma1.000e-05-pdc-dynamic-diag-ds4-seed-*-thresh0.00-0.0000-0.0195

# ./make-pdf-from-images.sh --dir=$DIR --name=$NAME

DATA=(
    # LEFT
    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p2-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p3-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p4-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p5-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p6-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p7-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p8-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p9-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p10-removed-pdc-dynamic-diag-f2048-41-ds4-seed-*-opnone-thresh0.00-0.0000-0.0049"

    "2017-07-13-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-*-removed-pdc-dynamic-diag-f2048-41-ds4-adjacency-idx192-768-0.0000-0.0024"
)

DIR="output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"

index=0
len=${#DATA[@]}
while [ $index -lt "$len" ]
do
    # get NAME
    NAME=${DATA[$index]}
    echo "DIR: " $DIR
    echo "NAME: " $NAME

    ./make-pdf-from-images.sh --dir=$DIR --name=$NAME

    # Next pair
    index=$(($index+1))
done
