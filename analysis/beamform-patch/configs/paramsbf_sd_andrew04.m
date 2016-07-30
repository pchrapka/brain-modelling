function params = paramsbf_sd_andrew04()
% params for subject 04

[srcdir,~,~] = fileparts(mfilename('fullpath'));

params = [];
params.name = 's04-10';
params.file = fullfile(srcdir,'..','..','data-andrew-beta','exp04_10.bdf');

%% create data specific configs
Eandrew_s04_cm();

%% assign configs for analysis
params.mri = 'MRIstd.mat';
params.hm = 'HMstd-cm.mat';
params.elec = 'Eandrew-s04-cm.mat';
params.lf = 'L1cm-norm-tight.mat';
params.eeg = ''; % TODO set up
params.bf = 'BFPatchAAL.mat';

end