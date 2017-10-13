function params = paramsbf_sd_beta(subject_num,deviant_percent,stimulus,varargin)
% params for subject from Andrew's beta study

p = inputParser();
addParameter(p,'patchmodel','aal',@ischar);
addParameter(p,'patchoptions',{},@iscell);
parse(p,varargin{:});

params_data = get_data_beta(subject_num,deviant_percent);

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
% BFPatchAAL();
% params_elec = Eandrew_warpgr_cm(elec_file, data_name);
params_elec = Eandrew_cm(params_data.elec_file, params_data.data_name);

% params_eeg = EEGandrew_stddev(data_file, data_name, stimulus);
params_eeg = EEGandrew_stddev_precomputed(params_data.data_file, params_data.data_name, stimulus);

switch p.Results.patchmodel
    case 'aal'
        params_bf = BFPatchAAL_andrew(params_data.data_name,p.Results.patchoptions{:});
    case 'aal-coarse-13'
        params_bf = BFPatchAAL13_andrew(params_data.data_name,p.Results.patchoptions{:});
    case 'aal-coarse-19'
        params_bf = BFPatchAAL19_andrew(params_data.data_name,p.Results.patchoptions{:});
    otherwise
        error('unknown model %s',p.Results.patchmodel);
end

%% assign configs for analysis
params = [];
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = params_bf;

end
