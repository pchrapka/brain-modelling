#!/bin/bash

# upload raw data
rsync -rvz --progress --exclude="/output" /media/phil/p.eanut/projects/data-andrew-beta/ chrapkpk@blade16:Documents/projects/data-andrew-beta/

#rsync -rvz --progress --exclude="/output" --exclude="*.bdf" --include="**/exp09*.bdf" /media/phil/p.eanut/projects/data-andrew-beta/ chrapkpk@blade16:Documents/projects/data-andrew-beta/

#rsync -rvz --progress --exclude="/output" /media/phil/p.eanut/projects/data-andrew-beta/exp13_10.bdf chrapkpk@blade16:Documents/projects/data-andrew-beta/
