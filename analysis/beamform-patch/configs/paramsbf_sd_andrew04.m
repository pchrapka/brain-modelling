function params = paramsbf_sd_andrew04()
% params for subject 04

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params = [];
params.name = 's04-10';
params.file = fullfile(srcdir,'..','..','data-andrew-beta','exp04_10.bdf');

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
Eandrew_s04_cm();

params_eeg = [];
params_eeg.name = 'EEGfake';

%% assign configs for analysis
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = 'Eandrew-s04-cm.mat';
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg; %''; % TODO set up
params.bf = 'BFPatchAAL.mat';

end