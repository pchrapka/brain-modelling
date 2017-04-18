#!/bin/bash

DATASETS=(
    # C113 no envelope
    #"2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    #"2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-info-seed-*-0.0073-0.0122"
    
    # C19 no envelope
    #"2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    #"2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122"
    
    # C19 envelope
    # "2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # C21 envelope
    # "2017-03-06-MCMTLOCCD_TWL2-T20-C21-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-06-MCMTLOCCD_TWL2-T20-C21-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C15 no envelope
    # "2017-03-08-MCMTLOCCD_TWL4-T20-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-08-MCMTLOCCD_TWL4-T20-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C15 no envelope, 40 trials
    # "2017-03-09-MCMTLOCCD_TWL4-T40-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-09-MCMTLOCCD_TWL4-T40-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C15 no envelope, 60 trials
    # "2017-03-09-MCMTLOCCD_TWL4-T60-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-09-MCMTLOCCD_TWL4-T60-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C15 envelope
    # "2017-03-07-MCMTLOCCD_TWL4-T20-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-07-MCMTLOCCD_TWL4-T20-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"
    
    # # C15 envelope, 40 trials
    # "2017-03-09-MCMTLOCCD_TWL4-T40-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-09-MCMTLOCCD_TWL4-T40-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C15 envelope, 60 trials
    # "2017-03-09-MCMTLOCCD_TWL4-T60-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-09-MCMTLOCCD_TWL4-T60-C15-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 40 trials
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 40 trials
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 60 trials
    # "2017-03-10-MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 60 trials
    # "2017-03-10-MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 40 trials, gamma 1e-2
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 40 trials, gamma 1e-2
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 40 trials, gamma 1e-1
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 40 trials, gamma 1e-1
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 20 trials, gamma 1e-3
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 20 trials, gamma 1e-3
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 20 trials, gamma 1e-2
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 20 trials, gamma 1e-2
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-02-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # # C12 no envelope, 20 trials, gamma 1e-1
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # # C12 envelope, 20 trials, gamma 1e-1
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    # "2017-03-10-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0000-0.0049"

    # C12 envelop, 20 trials, gamma 1e-3, significant
    #"2017-04-01-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-ds4-seed-*-thresh0.00-0.0000-0.0195"
    #"2017-04-01-MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-pdc-dynamic-diag-ds4-seed-*-threshsig-0.0000-0.0195"

    # C12 envelope, 20 trials, gamma 1e-5,
    "2017-04-14-MCMTLOCCD_TWL4-T20-C12-P11-lambda=0.9900-gamma=1.000e-05-pdc-dynamic-diag-ds4-seed-*-thresh0.00-0.0000-0.0195"
    "2017-04-14-MCMTLOCCD_TWL4-T20-C12-P11-lambda=0.9900-gamma=1.000e-05-pdc-dynamic-diag-ds4-seed-*-threshsig-estimate_ind_channels-0.0000-0.0195"
)

for DATASET in "${DATASETS[@]}"
do
    DATASETNAME="${DATASET/"-*"/}"
    echo "Working on "
    echo "    $DATASETNAME"

    OUTFILE=''

    while read -r EPSFILE; do
	OUTFILE=${EPSFILE/.eps/.pdf}
	if [ ! -f $OUTFILE ] || [ $EPSFILE -nt $OUTFILE ]; then
	    echo "Converting: $EPSFILE"
	    epstopdf "$EPSFILE"
	fi
    done < <(find ./output -name "$DATASET.eps")

    #echo outfile: $OUTFILE
    IMGDIR=$(dirname "${OUTFILE}")
    echo $IMGDIR
    PDFDIR="${IMGDIR/img/}"
    echo $PDFDIR

    echo "Merging"
    echo "    $DATASETNAME.pdf"
    find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'pdftk "$@" cat output '$PDFDIR$DATASETNAME'.pdf' "$0"
    
    # for debug
    #find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output '$DATASETNAME'.pdf' "$0"
done
