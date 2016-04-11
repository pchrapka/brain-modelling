#!/bin/bash

rsync -rvz --progress --include='*.m' --exclude='.git' --exclude='experiments/*/output' --exclude='experiments/output-common' --exclude='experiments/*/data' --exclude='*/fieldtrip-beamforming/anatomy' ~/projects/brain-modelling/ chrapkpk@blade16:Documents/projects/brain-modelling/
