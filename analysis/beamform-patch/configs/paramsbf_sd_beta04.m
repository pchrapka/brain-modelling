function params = paramsbf_sd_beta04(stimulus)
% params for subject 04

subject_num = 4;
deviant_percent = 10;
params_data = DataBeta(subject_num,deviant_percent);

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
params_elec = Eandrew_warpgr_cm(params_data.elec_file);

params_eeg = EEGandrew_stddev(params_data.data_file, params_data.data_name, stimulus);

%% assign configs for analysis
params = [];
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = 'BFPatchAAL.mat';

end
