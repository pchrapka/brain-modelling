PDC Asymptotic Package - AsympPDC v.2b
======================================

Installation:
============
This is an upgraded sequel to the first public release of AsympPDC package. It deals with the asymptotic statistics for PDC, gPDC and iPDC.

After unzipping the content of AsympPDC.zip file, save the folder structure into your machine working disk space, then set the Matlab path to all folder structure. 

AsympPDC runs under Matlab and is a practically self-contained except for requires routines from three Matlab toolboxes: Control System, Signal Processing, and Statistical. 
It is not extensively tested yet. It was partially tested under Windows, Macintosh and Linux environments with Matlab version 7.0 and higher. 

Additionally for cosmetic purposes, the xplot.m routine uses several Matlab users contributed codes: subplot2.m (modified old version of subplot to control spacing between subplots); shadedplot.m (developed by Dave Van Tol); suplabel.m (for label and title plotting in subplot figures, by Ben Barrowes); suptitle.m (contributed by Drea Thomas, for adding title above all subplots); tilefigs.m/tilefig.m (for tiling figures for simultaneous visualization, by Charles Plum / Mirko Hrovat, respectively); shadedErrorBar.m (by Rob Campbell); and boundedline.m (by Kelly Kearney).

Contents of the package:
=======================
a) Folder "routines" contains all Matlab codes for VAR estimation, PDC and asymptotic statistics calculation, Granger causality testing, and PDC cross-plotting routines used throughout the examples.

b) Folder "examples" contains 15 examples from 8 articles and a book. We believe these examples together with "pdc_analysis_template.m" may be instructive enough to anyone with some knowledge of Matlab and the Connectivity Analysis literature will be able to start analyzing his/her own data, and create batch processing code for real world data analysis.
b1) The "extras" subfolder contains data m-files for three of the examples used by pdc_analysis_template.m.

c) Folder "supporting" contains eight m-files for "cosmetic" plotting purposes.

d) Folders "Chap_04" and "Chap_07" contain the routines used to generate figures of Chapter 4 - Partial Directed Coherence and Chapter 7 - Asymptotic PDC Properties, respectively. 

Enjoy,

KS & LAB -- Sao Paulo - October 29, 2013.

PS: Please send any comments, incompatibilities and errors to ksameshi[at]usp.br or baccala[at]lcs.poli.usp.br.
