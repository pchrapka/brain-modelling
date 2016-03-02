%% fb_make_configs

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

% get configs
config_dir = 'configs';
files = dir(fullfile('configs','*.m'));
% compile mat files
for i=1:length(files)
    script = strrep(files(i).name, '.m', '');
    eval(script);
end