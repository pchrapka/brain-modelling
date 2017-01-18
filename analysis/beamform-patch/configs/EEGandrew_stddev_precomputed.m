function params_eeg = EEGandrew_stddev_precomputed(dataset, data_name, stimulus)
% EEGANDREW_STDDEV_PRECOMPUTED creates a subject specific config for ftb.EEG
%   EEGANDREW_STDDEV_PRECOMPUTED(dataset, data_name, stimulus) creates a
%   subject specific config for ftb.EEG
%
%   Input
%   -----
%   dataset (string)
%       path to data files
%   data_name (string)
%       subject prefix of eeg data file, i.e. prefix before -MMNf.eeg
%   stimulus (string)
%       type of stimulus: odd or std
%   
%   Output
%   ------
%   config_file (string)
%       file name of config

p = inputParser;
addRequired(p,'dataset',@ischar);
addRequired(p,'data_name',@ischar);
addRequired(p,'stimulus',@(x) any(validatestring(x,{'std','odd'})));
parse(p,dataset,data_name,stimulus);

dataset_name = [stimulus '-' data_name(1:3)];

params_eeg = [];
params_eeg.name = dataset_name;
params_eeg.mode = 'trial';

script_dir = fullfile(get_project_dir(), 'experiments', 'exp31-bf-beta');
outdir = fullfile(script_dir,'output',dataset_name);

fakefile = [tempname '.mat'];
data = [];
save(fakefile, 'data');

params_eeg.load_files = {...
    {'definetrial', fakefile},...
    {'preprocessed', fakefile},...
    {'timelock', fullfile(outdir,'ft_timelockanalysis.mat')},...
    };

subject_slug = strrep(data_name,'_','');
subject_slug = strrep(subject_slug,' ','');
config_file = [strrep(mfilename,'_','-') '-' subject_slug '-' stimulus '-precomputed.mat'];

[srcdir,~,~] = fileparts(mfilename('fullpath'));
save(fullfile(srcdir, config_file),'params_eeg');

end