#!/bin/bash

# Sources
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt


getopt --test > /dev/null
if [[ $? -ne 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

# specify options
SHORT=d:n:
LONG=dir:,name:

PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    # i.e. $? == 1
    # then getopt has complained about bad arguments
    exit 2
fi
#echo $PARSED

# modify positional arguments
# use eval to properly handle quoting
eval set -- "$PARSED"

while true; do
    case "$1" in
	-d|--dir)
	    DATADIR="$2"
	    shift 2
	    ;;
	-n|--name)
	    DATASET="$2"
	    shift 2
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    echo "Programming error"
	    exit 3
	    ;;
    esac
done

# handle non-option arguments?
	   
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
done < <(find ./"$DATADIR" -name "$DATASET.eps")

#echo outfile: $OUTFILE
IMGDIR=$(dirname "${OUTFILE}")
echo $IMGDIR
PDFDIR="${IMGDIR/img/}"
echo $PDFDIR

echo "Merging"
echo "    $DATASETNAME.pdf"
find ./"$DATADIR" -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'pdftk "$@" cat output '$PDFDIR$DATASETNAME'.pdf' "$0"
    
    # for debug
    #find ./output -name "$DATASET.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output '$DATASETNAME'.pdf' "$0"
	   
