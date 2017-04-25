%% setup paths and environment
% add the current directory
addpath(pwd);

startup_project;

%% add data
addpath(fullfile(pwd,'..','data-headmodel','mni152'));

%% add external packages
addpath(fullfile(pwd,'external'));
addpath(fullfile(pwd,'external','subaxis'));
addpath(fullfile(pwd,'external','kronm'));
addpath(fullfile(pwd,'external','tsa'));
addpath(fullfile(pwd,'external','bct'));
addpath(fullfile(pwd,'external','lumberjack'));
addpath(fullfile(pwd,'external','export_fig'));
addpath(fullfile(pwd,'external','heatmaps'));
addpath(fullfile(pwd,'external','psom-1.2.1'));
addpath(fullfile(pwd,'external','ProgressBar'));
addpath(fullfile(pwd,'external','libsvm-321','matlab'));
addpath(fullfile(pwd,'external','LSPC'));
addpath(fullfile(pwd,'external','FEAST-v1.1.1','FEAST'));
addpath(fullfile(pwd,'external','FEAST-v1.1.1','MIToolbox'));
addpath(fullfile('external','bayesopt','matlab'));
addpath(genpath(fullfile(pwd,'external','AutomaticSpectra')));
addpath(fullfile(pwd,'external','asymp_package_v2b','routines'));
addpath(genpath(fullfile(pwd,'external','asymp_package_v2b','supporting')));

%% add external packages with setup steps
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

addpath(fullfile(pwd,'external','kafbox-1.4'));
addpath(genpath(fullfile(pwd,'external','kafbox-1.4','data')));
addpath(genpath(fullfile(pwd,'external','kafbox-1.4','lib')));
%addpath((fullfile(pwd,'demo')));

curdir = pwd;
cd(fullfile(pwd,'external','ARMASA_1_9','ARMASA'));
ASAaddpath();
cd(curdir);

% check bayesopt
if ~exist('bayesoptcont.mexa64','file')
    % Compile bayesopt
    fprintf('Compiling bayesopt\n');
    curdir = pwd;
    cd(fullfile('external','bayesopt','matlab'));
    try
        compile_matlab
    catch
        fprintf(['Something went wrong. bayesopt did not compile.\n'...
            'follow compilation instructions here:\n'...
            'https://rmcantin.bitbucket.io/html/install.html\n']);
    end
    cd(curdir);
end



%% add project directories
addpath(fullfile(pwd,'methods'));
addpath(fullfile(pwd,'methods','ar-process'));
addpath(fullfile(pwd,'methods','adaptive-filter'));
addpath(fullfile(pwd,'methods','analysis'));
addpath(fullfile(pwd,'methods','beamformer'));
addpath(fullfile(pwd,'methods','classification'));
addpath(fullfile(pwd,'methods','connectivity'));
addpath(fullfile(pwd,'methods','ft_private'));
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