#!/bin/bash

DATASETS=(
    #"2017-02-18-MCMTLOCCD_TWL2-T40-C113-P10-lambda=0.99-gamma=1.00-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    #"2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    #"2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    #"2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-info-seed-*-0.0073-0.0122"
    
    # C19 no envelope
    #"2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    #"2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    #"2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122"
    
    # C19 envelope
    "2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-euc-seed-*-0.0073-0.0122"
    "2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0073-0.0122"
    "2017-03-02-MCMTLOCCD_TWL2-T20-C19-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0073-0.0122"

    # C21 envelope
    "2017-03-06-MCMTLOCCD_TWL2-T20-C21-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-euc-seed-*-0.0000-0.0049"
    "2017-03-06-MCMTLOCCD_TWL2-T20-C21-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-diag-seed-*-0.0000-0.0049"
    "2017-03-06-MCMTLOCCD_TWL2-T20-C21-P3-lambda=0.9800-gamma=1.000e-03-pdc-dynamic-info-seed-*-0.0000-0.0049"
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
    #echo $IMGDIR
    PDFDIR="${IMGDIR/img/}"
    #echo $PDFDIR

    echo "Merging"
    echo "    $DATASETNAME.pdf"
    find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'pdftk "$@" cat output '$PDFDIR$DATASETNAME'.pdf' "$0"
    
    # for debug
    #find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output '$DATASETNAME'.pdf' "$0"
done
