%% setup paths and environment

% Get the user's Matlab directory
matlab_dir = userpath;
matlab_dir = matlab_dir(1:end-1);

% Add the current directory
addpath(pwd);
% addpath(fullfile(pwd,'util'));
% addpath(fullfile(pwd,'external'));

% Add external packages
% addpath(fullfile(pwd,'external','subaxis'));

% Add all experiment directories
addpath(genpath(fullfile(pwd,'experiments')));