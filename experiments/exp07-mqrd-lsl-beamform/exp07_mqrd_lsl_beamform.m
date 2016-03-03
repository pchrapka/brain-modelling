%% exp07_mqrd_lsl_beamform
% Goal: 
%   Apply MQRD-LSL on beamformed EEG data

close all;

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Create analysis step objects

% Create custom configs
DSarind_cm();

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = 'HMdipoli-cm.mat';
hm = ftb.Headmodel(params_hm,'dipoli-cm');

params_e = 'E128-cm.mat';
e = ftb.Electrodes(params_e,'128-cm');
% e.force = true;

params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm');
% lf.force = false;

params_dsim = 'DSarind-cm.mat';
dsim = ftb.DipoleSim(params_dsim,'arind-cm');
dsim.force = true;
 
params_bf = 'BFlcmv.mat';
bf = ftb.Beamformer(params_bf,'lcmv');

%% Set up beamformer analysis
out_folder = fullfile(srcdir,'output');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%% Add analysis steps
analysis.add(m);

analysis.add(hm);
% figure;
%hm.plot({'brain','skull','scalp','fiducials'})

analysis.add(e);
% figure;
% e.plot({'brain','skull','scalp','fiducials','electrodes-aligned','electrodes-labels'})

analysis.add(lf);
% figure;
% lf.plot({'brain','skull','scalp','fiducials','leadfield'});
% 
analysis.add(dsim);
% figure;
% dsim.plot({'brain','skull','scalp','fiducials','dipole'});

analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();


%% Plot all results
figure;
bf.plot({'brain','skull','scalp','fiducials','dipole'});
figure;
bf.plot_scatter([]);
bf.plot_anatomical();