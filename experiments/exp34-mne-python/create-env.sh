#!/bin/bash

conda create --name mne python=2.7 ipython notebook
source activate mne
conda install mne pysurfer
