function fb_install()
%FB_INSTALL install the fieldtrip-beamforming package
%   FB_INSTALL install the fieldtrip-beamforming package

[srcdir,~,~] = fileparts(mfilename('fullpath'));

% add fieldtrip-beamforming
addpath(srcdir);
addpath(fullfile(srcdir,'configs'));
addpath(fullfile(srcdir,'ft_extensions'));

% add fieldtrip-beamforming external packages
addpath(fullfile(srcdir,'external'));
addpath(fullfile(srcdir,'external','phasereset'));    % add phasereset

% check for fieldtrip toolbox
if ~exist('ft_defaults','file')
    error(['ftb:' mfilename],...
        ['fieldtrip does not exist.\n'...
        'Please check the path to your fieldtrip installtion.\n']);
end

% %% Add fieldtrip
% % get the user's Matlab directory
% matlab_dir = userpath;
% matlab_dir = matlab_dir(1:end-1);
% 
% % dep_path = fullfile(matlab_dir,'fieldtrip-20150127');
% dep_path = fullfile(matlab_dir,'fieldtrip-20160128');
% if ~exist(dep_path,'dir')
%     error(['fb:' mfilename],...
%         ['%s does not exist.\n'...
%         'Please check the path to your fieldtrip installtion.\n'], dep_path);
% end
% addpath(dep_path);
% ft_defaults
% 
% % Add private fieldtrip functions
% % Copy the private functions into a new directory and make them not private
% oldpath = fullfile(dep_path, 'private');
% newpath = fullfile(dep_path, 'private_not');
% copyfile(oldpath, newpath);
% addpath(newpath);

end