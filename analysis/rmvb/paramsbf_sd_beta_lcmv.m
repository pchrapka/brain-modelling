function params = paramsbf_sd_beta_lcmv(subject_num,deviant_percent,stimulus,varargin)
% params for subject from Andrew's beta study

% p = inputParser();
% parse(p,varargin{:});

meta_data = DataBeta(subject_num,deviant_percent);

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
% BFPatchAAL();
% params_elec = Eandrew_warpgr_cm(elec_file, data_name);
params_elec = Eandrew_cm(meta_data);

% params_eeg = EEGandrew_stddev(data_file, data_name, stimulus);

% TODO get rid of computer specific code in the following function
% use a parameter here instead
params_eeg = EEGandrew_stddev_precomputed(meta_data, stimulus);

params_bf = BFLCMV_beta(meta_data,varargin{:});

%% assign configs for analysis
params = [];
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = params_bf;

end
