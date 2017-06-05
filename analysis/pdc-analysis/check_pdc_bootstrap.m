% check_pdc_bootstrap

flag_test = false;
if flag_test
    file_pdc_sig = fullfile('/home/phil/projects/brain-modelling/analysis/pdc-analysis',...
        'output/vrc-cp-ch2-coupling2-rnd-c12-v3',...
        'MCMTLOCCD_TWL4-T5-C12-P3-lambda=0.9900-gamma=1.000e+00-bootstrap',...
        'pdc-dynamic-diag-ds4-sig-n10-alpha0.05.mat');
else
    file_pdc_sig = fullfile('/home/chrapkpk/Documents/projects/brain-modelling',...
        'analysis/pdc-analysis/output/std-s03-10/aal-coarse-19-outer-nocer-plus2',...
        'lf-sources-ch12-trials100-samplesall-normallchannels-envyes',...
        'MCMTLOCCD_TWL4-T20-C12-P3-lambda=0.9900-gamma=1.000e-03-bootstrap',...
        'pdc-dynamic-diag-ds4-sig-n100-alpha0.05.mat');
end

%% check pdc resampled data set
stimulus = 'std';
subject = 3;
deviant_percent = 10;

patch_options = {...
    'patchmodel','aal-coarse-19',...
    'patchoptions',{'outer',true,'cerebellum',false,'flag_add_auditory',true}};
out = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_options);
pipeline = out.pipeline;
outdir = out.outdir;

eeg_file = fullfile(outdirbase,'fthelpers.ft_phaselocked.mat');
leadfield_file = pipeline.steps{end}.lf.leadfield;

envelope = true;
resample_idx = 1;

% NOTE old code
warning('old code');
pdc_bootstrap_check_resample(file_pdc_sig,resample_idx,...
    'envelope',envelope,...
    'eeg_file',eeg_file,'leadfield_file',leadfield_file);

%%  check pdc distribution
if flag_test
    sample_idx = 40;
    w_range = [0.2 0.3];
else
    sample_idx = 500;
    downsample_by = 4;
    fsample = 2048/downsample_by;
    w_range = [0 10/fsample];
end

pdc_bootstrap_check_distr(file_pdc_sig,sample_idx,'mode','all','w_range',w_range);
