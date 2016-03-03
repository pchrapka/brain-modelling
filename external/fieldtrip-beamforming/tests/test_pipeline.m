%% test_pipeline

close all;

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

% POSSIBLE BUGS
%   1. Deleted files are not counted as a dependency change, I think the only
%   solution here would require time stamp comparisons

% NOTES
%   

% TODO
%   - Set up TestAnalysisStep to test non-abstract functions, using other
%   AnalysisStep subclasses
%   - Rethink complex dipole simulations, will need more objects for this

%% Create analysis step objects

config_dir = fullfile('..','configs');

% MRI
params_mri = fullfile(config_dir, 'MRIS01.mat');
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = fullfile(config_dir, 'HMdipoli-cm.mat');
hm = ftb.Headmodel(params_hm,'dipoli-cm');

params_e = fullfile(config_dir, 'E128-cm.mat');
e = ftb.Electrodes(params_e,'128-cm');
e.force = false;

% params_lf = fullfile(config_dir, 'L10mm-norm.mat');
% lf = ftb.Leadfield(params_lf,'10mm-norm');

% 1cm normalized
params_lf = fullfile(config_dir, 'L1cm-norm.mat');
lf = ftb.Leadfield(params_lf,'1cm-norm');

% % 1cm unnormalized
% params_lf = fullfile(config_dir, 'L1cm.mat');
% lf = ftb.Leadfield(params_lf,'1cm');

lf.force = false;

% params_dsim = fullfile(config_dir, 'DSsine-cm.mat');
% dsim = ftb.DipoleSim(params_dsim,'sine-cm');

% multiple sources
DSdip3_sine_cm();
params_dsim = fullfile(config_dir, 'DSdip3-sine-cm.mat');
dsim = ftb.DipoleSim(params_dsim,'dip3-sine-cm');

dsim.force = true;

% params_dsim = fullfile(config_dir, 'DSsine-test1.mat');
% dsim = ftb.DipoleSim(params_dsim,'sine-test1');

params_bf = fullfile(config_dir, 'BFlcmv.mat');
bf = ftb.Beamformer(params_bf,'lcmv');

%% Set up beamformer analysis
out_folder = 'output';
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%%
analysis.add(m);
analysis.init();
% analysis.process();

%%
analysis.add(hm);
analysis.init();
% analysis.process();
% figure;
%hm.plot({'brain','skull','scalp','fiducials'})

%%
analysis.add(e);
analysis.init();
% analysis.process();

% figure;
% e.plot({'brain','skull','scalp','fiducials','electrodes-aligned','electrodes-labels'})

%%
analysis.add(lf);
analysis.init();
% analysis.process();

% figure;
% lf.plot({'brain','skull','scalp','fiducials','leadfield'});

%% 
analysis.add(dsim);
analysis.init();
% analysis.process();

% figure;
% dsim.plot({'brain','skull','scalp','fiducials','dipole'});

%%
analysis.add(bf);
analysis.init();
analysis.process();

figure;
dsim.plot_data('simulated');

figure;
dsim.plot_data('timelock');

figure;
bf.plot({'brain','skull','scalp','fiducials','dipole'});
figure;
bf.plot_scatter([]);
% bf.plot_anatomical();