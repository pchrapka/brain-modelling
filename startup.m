%% setup paths and environment

% add the current directory
addpath(pwd);

% add external packages
addpath(fullfile(pwd,'external'));
addpath(fullfile(pwd,'external','subaxis'));
addpath(fullfile(pwd,'external','tsa'));
addpath(fullfile(pwd,'external','lumberjack'));
addpath(fullfile(pwd,'external','export_fig'));

% pkg_dir = fullfile(pwd,'external','biosig4octmat-3.0.1');
% curdir = pwd;
% cd(pkg_dir)
% biosig_installer;
% cd(curdir);
% clear all;

addpath(fullfile(pwd,'external','fieldtrip-beamforming'));
fb_install()
fb_make_configs()

% add methods directory
addpath(fullfile(pwd,'methods'));

% add all experiment directories
% FIXME i want to keep my experiments independent, so this is probably not
% a good idea
% addpath(genpath(fullfile(pwd,'experiments')));