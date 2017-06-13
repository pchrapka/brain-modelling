#!/bin/bash

DIR=output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normeachchannel-envyes-for-filter
NAME=2017-04-14-MCMTLOCCD_TWL4-T20-C12-P11-lambda=0.9900-gamma=1.000e-05-pdc-dynamic-diag-ds4-seed-*-thresh0.00-0.0000-0.0195

./make-pdf-from-images.sh --dir=$DIR --name=$NAME
