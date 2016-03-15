function [ data ] = raw2fieldtrip( cfg )
%RAW2FIELDTRIP Converts raw EEG data to FieldTrip format
%   RAW2FIELDTRIP(CFG) converts raw EEG data to a format that's useable
%   with FieldTrip.
%
%   cfg requires the following fields
%   cfg.n_channels
%   cfg.n_trials
%   cfg.label       
%       channel labels (n_channels x 1)
%   cfg.fsample     
%       sampling rate (Hz)
%   cfg.trial       
%       cell array of trial data with the following fields:
%           data 
%               data (n_channels x n_samples)
%           time    
%               time axis (1 x n_samples)
%           info    
%               (optional) cell array of additional info for each trial,
%               length(info_hdr)
%   cfg.info_hdr    
%       (optional) headers for additional trial info 
%
%   save the converted data (optional)
%   cfg.out_dir     Output directory for files
%   cfg.file_name   Output file name root
%   cfg.file_name_suf (optional)
%           suffix for the file name
%
%   Source:
%   http://fieldtrip.fcdonders.nl/faq/how_can_i_import_my_own_dataformat

% FIXME Good candidate for a inter project utilities project

n_channels = cfg.n_channels;
n_trials = cfg.n_trials;

%% Channel labels
if isequal(length(cfg.label), n_channels)
    data.label = cell(n_channels, 1);
    % Copy the channel labels (Nchan x 1)
    [data.label{:}] = cfg.label{:};
else
    error(...
        'lumberjack:raw2fieldtrip',...
        ['cfg.label should contain ' num2str(n_channels) ' cells']);
end

%% Sampling rate
% Copy the sampling rate
data.fsample = cfg.fsample;

%% Trials
if isequal(size(cfg.trial,1), n_trials);
    data.trial = cell(1, n_trials);
    data.time = cell(1, n_trials);
    
    if isfield(cfg,'info_hdr')
        n_info_fields = length(cfg.info_hdr);
        data.trialinfo = cell(n_trials, n_info_fields);
        data.trialinfo_hdr = cfg.info_hdr;
    end
    for i=1:n_trials
        % Get the number of samples
        n_samples = length(cfg.trial{i}.time);
        data.sampleinfo = [1 n_samples];
        % Get the trial data
        if isequal(size(cfg.trial{i}.data), [n_channels n_samples])
            data.trial{i} = cfg.trial{i}.data;
        else
            error(...
                'lumberjack:raw2fieldtrip',...
                'cfg.trial.data is a bad size');
        end
        % Get the time axis
        data.time{i} = reshape(...
            cfg.trial{i}.time,...
            1, n_samples);
        
        if isfield(data,'trialinfo')
            % Get the additional information
            [data.trialinfo{i,:}] = cfg.trial{i}.info{:};
        end
    end
else
    error(...
        'lumberjack:raw2fieldtrip',...
        ['cfg.trial should contain ' num2str(n_trials) ' cells']);
end

%% Save the data
if isfield(cfg, 'out_dir')
    % Create the directory if it doesn't exist
    if ~exist(cfg.out_dir, 'dir')
        mkdir(cfg.out_dir);
    end
    % Set up the file name
    if isfield(cfg, 'file_name_suf') && ~isempty(cfg.file_name_suf)
        out_file = fullfile(cfg.out_dir,...
            [cfg.file_name '_' cfg.file_name_suf '.mat']);
    else
        out_file = fullfile(cfg.out_dir,...
            [cfg.file_name '.mat']);
    end
    save(out_file, 'data');
end

end

