% check_pdc_bootstrap

stimulus = 'std';
subject = 3;
deviant_percent = 10;

patch_type = 'aal-coarse-19-outer-nocer-plus2';

[pipeline,outdirbase] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_type);

eeg_file = fullfile(outdirbase,'fthelpers.ft_phaselocked.mat');
leadfield_file = pipeline.steps{end}.lf.leadfield;

envelope = true;
resample_idx = 1;

pdc_sig_file = fullfile('/home/chrapkpk/Documents/projects/brain-modelling',...
    'analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2',...
    'lf-sources-ch12-trials100-samplesall-normallchannels-envyes',...
    'MCMTLOCCD_TWL4-T40-C12-P3-lambda=0.9900-gamma=1.000e-03-bootstrap',...
    'pdc-dynamic-diag-ds4-sig-n100-alpha0.05.mat');


pdc_bootstrap_check_resample(pdc_sig_file,resample_idx,...
    'envelope',envelope,'patch_type',patch_type,...
    'eeg_file',eeg_file,'leadfield_file',leadfield_file);