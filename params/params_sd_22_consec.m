function params = params_sd_22_consec()
% params for subject 22 with consecutive std, odd trials

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params = [];
params.subject_id = 22;

params.conds(1).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstdconsec-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(1).opt_func = 'params_al_std';

params.conds(2).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGoddconsec-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(2).opt_func = 'params_al_odd';

end