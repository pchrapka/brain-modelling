%% setup paths and environment

% add the current directory
addpath(pwd);

%% add external packages
addpath(fullfile(pwd,'external'));
addpath(fullfile(pwd,'external','subaxis'));
addpath(fullfile(pwd,'external','tsa'));
addpath(fullfile(pwd,'external','lumberjack'));
addpath(fullfile(pwd,'external','export_fig'));
addpath(fullfile(pwd,'external','heatmaps'));
addpath(fullfile(pwd,'external','psom-1.2.1'));
addpath(fullfile(pwd,'external','libsvm-321','matlab'));
addpath(fullfile(pwd,'external','FEAST-v1.1.1','FEAST'));
addpath(fullfile(pwd,'external','FEAST-v1.1.1','MIToolbox'));

%% check compiled files
% Check fEAST has been compiled
if ~exist('FSToolboxMex.mexa64','file')
    % Compile FEAST
    fprintf('Compiling FEAST\n');
    curdir = pwd;
    cd(fullfile('external','FEAST-v1.1.1','FEAST'));
    try
        CompileFEAST
    catch
        fprintf('Something went wrong. FEAST did not compile\n');
    end
    cd(curdir);
end

% check libsvm
if ~exist('svmtrain.mexa64','file')
    curdir = pwd;
    cd(fullfile('external','libsvm-321','matlab'));
    try
        make
    catch
        fprintf('Something went wrong. libsvm did not compile\n');
    end
    cd(curdir);
end

addpath(fullfile(pwd,'external','fieldtrip-20160128'));
ft_defaults();

% pkg_dir = fullfile(pwd,'external','biosig4octmat-3.0.1');
% curdir = pwd;
% cd(pkg_dir)
% biosig_installer;
% cd(curdir);
% clear all;

addpath(fullfile(pwd,'external','fieldtrip-beamforming'));
fb_install()
fb_make_configs()

%% add project directories
addpath(fullfile(pwd,'methods'));
addpath(fullfile(pwd,'analysis'));
addpath(fullfile(pwd,'params'));
addpath(fullfile(pwd,'visualizations'));

%% archived functions
% keep for older scripts
% make sure to include deprecated warnings
addpath(fullfile(pwd,'methods','archive'));