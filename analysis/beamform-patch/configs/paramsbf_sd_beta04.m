function params = paramsbf_sd_beta04(stimulus)
% params for subject 04

subject_num = 4;
deviant_percent = 10;
[data_file,data_name,elec_file] = get_data_beta(subject_num,deviant_percent);

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
params_elec = Eandrew_warpgr_cm(elec_file);

params_eeg = EEGandrew_stddev(data_file, data_name, stimulus);

%% assign configs for analysis
params = [];
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = 'BFPatchAAL.mat';

end
