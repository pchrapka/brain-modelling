%% setup paths and environment

% % get the user's Matlab directory
% matlab_dir = userpath;
% matlab_dir = matlab_dir(1:end-1);

% add the current directory
addpath(pwd);

% add external packages
addpath(fullfile(pwd,'external'));
addpath(fullfile(pwd,'external','subaxis'));

pkg_dir = fullfile(pwd,'external','biosig4octmat-3.0');
curdir = pwd;
cd(pkg_dir)
biosig_installer;
cd(curdir);
clear all;

addpath(fullfile(pwd,'external','fieldtrip-beamforming'));
fb_install()
fb_make_configs()

% add methods directory
addpath(fullfile(pwd,'methods'));

% add all experiment directories
addpath(genpath(fullfile(pwd,'experiments')));