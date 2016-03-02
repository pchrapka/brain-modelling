%% fb_demo
% demos the fieldtrip-beamforming project

close all;

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

%% Create analysis step objects

config_dir = fullfile('..','configs');

% MRI
params_mri = fullfile(config_dir, 'MRIS01.mat');
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = fullfile(config_dir, 'HMbemcp-cm.mat');
hm = ftb.Headmodel(params_hm,'bemcp-cm');

params_e = fullfile(config_dir, 'E128-cm.mat');
e = ftb.Electrodes(params_e,'128-cm');
e.force = true;

params_lf = fullfile(config_dir, 'L1cm-norm.mat');
lf = ftb.Leadfield(params_lf,'1cm-norm');
lf.force = false;

params_dsim = fullfile(config_dir, 'DSsine-cm.mat');
dsim = ftb.DipoleSim(params_dsim,'sine-cm');
dsim.force = false;

params_bf = fullfile(config_dir, 'BFlcmv.mat');
bf = ftb.Beamformer(params_bf,'lcmv');

%% Set up beamformer analysis
out_folder = 'output';
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

analysis.add(dsim);
% figure;
% dsim.plot({'brain','skull','scalp','fiducials','dipole'});

analysis.add(bf);

figure;
bf.plot({'brain','skull','scalp','fiducials','dipole'});
figure;
bf.plot_scatter([]);
bf.plot_anatomical();