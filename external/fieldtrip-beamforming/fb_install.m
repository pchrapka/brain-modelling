%% fb_install.m

% switch to project folder
curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

% Get the user's Matlab directory
matlab_dir = userpath;
matlab_dir = matlab_dir(1:end-1);

%% Add packages to the Matlab path

% add fieldtrip-beamforming
addpath(pwd);
addpath(fullfile(pwd,'configs'));
addpath(fullfile(pwd,'ft_extensions'));

% add fieldtrip-beamforming external packages
addpath(fullfile(pwd,'external'));
addpath(fullfile(pwd,'external','phasereset'));    % add phasereset

% Add fieldtrip
% dep_path = fullfile(matlab_dir,'fieldtrip-20150127');
dep_path = fullfile(matlab_dir,'fieldtrip-20160128');
if ~exist(dep_path,'dir')
    error(['fb:' mfilename],...
        ['%s does not exist.\n'...
        'Please check the path to your fieldtrip installtion.\n'], dep_path);
end
addpath(dep_path);
ft_defaults

% Add private fieldtrip functions
% Copy the private functions into a new directory and make them not private
oldpath = fullfile(dep_path, 'private');
newpath = fullfile(dep_path, 'private_not');
copyfile(oldpath, newpath);
addpath(newpath);

% TODO wget anatomy data, or is it available in fieldtrip?

% return to working dir
cd(curdir);
clear all;