%% startup_project

%% add project directories
addpath(fullfile(pwd,'methods'));
addpath(fullfile(pwd,'methods','ar-process'));
addpath(fullfile(pwd,'methods','adaptive-filter'));
addpath(fullfile(pwd,'methods','analysis'));
addpath(fullfile(pwd,'methods','beamformer'));
addpath(fullfile(pwd,'methods','classification'));
addpath(fullfile(pwd,'methods','connectivity'));
addpath(fullfile(pwd,'methods','modelling'));
addpath(fullfile(pwd,'methods','stats'));
addpath(fullfile(pwd,'methods','util'));
addpath(fullfile(pwd,'analysis'));
addpath(fullfile(pwd,'analysis','lattice-svm'));
addpath(fullfile(pwd,'analysis','lattice-svm','params'));
addpath(fullfile(pwd,'analysis','beamform-patch'));
addpath(fullfile(pwd,'analysis','beamform-patch','tests'));
addpath(fullfile(pwd,'analysis','beamform-patch','configs'));
addpath(fullfile(pwd,'visualizations'));

%% archived functions
% keep for older scripts
% make sure to include deprecated warnings
addpath(fullfile(pwd,'methods','archive'));