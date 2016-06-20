function params = params_sd_22()
% params for subject 22

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params = [];
params.subject_id = 22;

params.conds(1).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGstd-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(1).opt_func = 'params_al_std';

params.conds(2).file = fullfile(srcdir,...
    ['../experiments/output-common/fb/'...
    'MRIstd-HMstd-cm-EP022-9913-L1cm-norm-tight-EEGodd-BPatchTriallcmvmom/'...
    'sourceanalysis.mat']);
params.conds(2).opt_func = 'params_al_odd';

end