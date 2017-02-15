#!/bin/bash

echo "Converting eps to pdf"
find ./output -name "*seed*.eps" -exec epstopdf {} \;

echo "Merging pdf"
find ./output -name "*seed*.pdf" -print0 | sort -zn | xargs -0 sh -c 'set -x; pdftk "$@" cat output pdc-seed.pdf' "$0""
