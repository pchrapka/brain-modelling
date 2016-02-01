%% setup paths and environment

% % get the user's Matlab directory
% matlab_dir = userpath;
% matlab_dir = matlab_dir(1:end-1);

% add the current directory
addpath(pwd);
% addpath(fullfile(pwd,'util'));
% addpath(fullfile(pwd,'external'));

% add external packages
% addpath(fullfile(pwd,'external','subaxis'));

% add methods directory
addpath(fullfile(pwd,'methods'));

% add all experiment directories
addpath(genpath(fullfile(pwd,'experiments')));