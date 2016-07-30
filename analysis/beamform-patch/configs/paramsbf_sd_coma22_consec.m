function params = paramsbf_sd_coma22_consec(stimulus)
% params for subject 22

[~,func_name,~] = fileparts(mfilename('fullpath'));

% subject specific info
[datadir,subject_file,subject_name] = get_coma_data(22);

params = [];
params.name = [func_name '_' stimulus];

%% create data specific configs
params_elec = [];
params_elec.name = ['E' subject_name];
params_elec.elec_orig = fullfile(datadir,[subject_file '.sfp']);
params_elec.fiducials = {'NAS','NZ','LPA','LPA','RPA','RPA'};

params_eeg = EEGstddevconsec(datadir, subject_file, stimulus);

BFPatchAAL13();

%% assign configs for analysis
params.mri = 'MRIstd.mat';
params.hm = 'HMstd-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = 'BFPatchAAL13.mat';

end