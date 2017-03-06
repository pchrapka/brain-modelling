
#DATASETS += "2017-02-18-MCMTLOCCD_TWL2-T40-C113-P10-lambda=0.99-gamma=1.00-pdc-dynamic-euc-seed-*-0.0073-0.0122"
DATASETS = "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-%-0.0073-0.0122"
#DATASETS += "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-diag-seed-*-0.0073-0.0122"
#DATASETS += "2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-info-seed-*-0.0073-0.0122"
#DATASETS += "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-euc-seed-*-0.0073-0.0122"
#DATASETS += "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-diag-seed-*-0.0073-0.0122"
#DATASETS += "2017-02-28-MCMTLOCCD_TWL2-T20-C13-P3-lambda=0.9900-gamma=1.000e-01-pdc-dynamic-info-seed-*-0.0073-0.0122"

#2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-%-0.0073-0.0122.pdf: 2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-%-0.0073-0.0122.eps

seed1: DATAGLOB=2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-*-0.0073-0.0122.eps
seed1: FILEOUT=2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-0.0073-0.0122.pdf
seed1: FILESEPS:=$(shell find ./output -name "$(DATAGLOB)")
#seed1: FILESEPS=$(wildcard $DATAGLOB)
seed1: FILESIN:=$(patsubst %.eps, %.pdf, $(FILESEPS))
#seed1: $(FILESEPS)
#
seed2: DATAGLOB=this

seeds = seed1 seed2

#%.pdf: %.eps
#	@echo "Converting $@"
#	epstopdf $<

#.SUFFIXES: .eps .pdf

$(FILESEPS): %.pdf: %.eps
	@echo "Converting $<"	
	epstopdf $<

#2017-02-28-MCMTLOCCD_TWL2-T20-C113-P3-lambda=0.9900-gamma=1.000e-04-pdc-dynamic-euc-seed-0.0073-0.0122.pdf :

$(seeds) : $(FILESIN)
	@echo DATAGLOB= $(DATAGLOB)
	@echo FILEOUT= $(FILEOUT)
	@echo FILESEPS= $(FILESEPS)
	@echo FILESIN= $(FILESIN)
	@echo "Merging $(FILEOUT)"
#	@pdftk $(FILESIN) cat output $(FILEOUT)

all: $(seeds)
#	seed1:


#	echo $(DATASETS)
#seed-euc: $(PDFS)
#	for DATASET in $(DATASETS); do \
#		pdftk $(PDFS) cat output $(DATASETNAME).pdf \
#	done
