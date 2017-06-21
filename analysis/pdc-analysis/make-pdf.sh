#!/bin/bash

# # Test
# DIR=output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-for-filter
# NAME=2017-04-14-MCMTLOCCD_TWL4-T20-C12-P11-lambda0.9900-gamma1.000e-05-pdc-dynamic-diag-ds4-seed-*-thresh0.00-0.0000-0.0195

# ./make-pdf-from-images.sh --dir=$DIR --name=$NAME

DATA=(
    # LEFT 
    "output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-03-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"

    "output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P7-lambda0.9900-gamma1.000e-04-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"

    # a few tries for gamma 1e-4
    #"output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    #"2017-06-14-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-04-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"

    #"output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    #"2017-06-14-MCMTLOCCD_TWL4-T20-C7-P14-lambda0.9900-gamma1.000e-04-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"
    
    "output/std-s03-10/aal-coarse-19-outer-nocer-hemileft-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P5-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"

    # RIGHT
    "output/std-s03-10/aal-coarse-19-outer-nocer-hemiright-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P6-lambda0.9900-gamma1.000e-03-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"

    "output/std-s03-10/aal-coarse-19-outer-nocer-hemiright-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P7-lambda0.9900-gamma1.000e-04-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"
    
    "output/std-s03-10/aal-coarse-19-outer-nocer-hemiright-audr2-v1r2/lf-data-trialsall-samplesall-normeachchannel-envyes-prependflipdata"
    "2017-06-20-MCMTLOCCD_TWL4-T20-C7-P3-lambda0.9900-gamma1.000e-05-p1-removed-pdc-dynamic-diag-f512-ds4-seed-*-opnone-thresh0.00-0.0000-0.0098"
    )

index=0
len=${#DATA[@]}
while [ $index -lt "$len" ]
do
    # get DIR and NAME
    DIR=${DATA[$index]}
    NAME=${DATA[$index+1]}
    echo "DIR: " $DIR
    echo "NAME: " $NAME

    ./make-pdf-from-images.sh --dir=$DIR --name=$NAME

    # Next pair
    index=$(($index+2))
done