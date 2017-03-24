%% test_bootstrap

lf_file = '/home-new/chrapkpk/Documents/projects/brain-modelling/analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2/lf-sources-ch12-trials100-samplesall-normallchannels-envno/MCMTLOCCD_TWL4-T60-C12-P3-lambda=0.9900-gamma=1.000e-03.mat';

% select pdc params
pdc_params = {'downsample',4,'metric','diag'};
pdc_bootstrap(lf_file,'nresamples',1,'alpha',0.05,'pdc_params',pdc_params{:});