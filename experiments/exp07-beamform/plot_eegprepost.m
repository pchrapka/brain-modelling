function plot_eegprepost(eeg_prepost, varargin)
%PLOT_EEGPREPOST plots EEGPrePost object 
%   PLOT_EEGPREPOST(eeg_prepost, [name, value]) plots EEGPrePost object 
%
%   Input
%   -----
%   eeg_prepost (EEGPrePost object)
%       EEGPrePost object
%
%   Parameter options
%   preprocessed (boolean)
%       plots preprocessed data
%   timelock (boolean)
%       plots timelocked data
%   save (boolean)
%       flag for saving images

% parse inputs
p = inputParser;
p.StructExpand = false;
addParameter(p,'preprocessed',false,@islogical);
addParameter(p,'timelock',false,@islogical);
addParameter(p,'save',false,@islogical);
parse(p,varargin{:});

%% EEG plots

if p.Results.preprocessed
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    cfg.channel = 'Cz';
    eegObj.plot_data('preprocessed',cfg)
end

if p.Results.timelock
    %type = 'post';
    %type = 'pre';
    type = 'all';
    switch type
        case 'all'
            eegObj = eeg_prepost;
        case 'pre'
            eegObj = eeg_prepost.pre;
        case 'post'
            eegObj = eeg_prepost.post;
    end
    cfg = [];
    %cfg.channel = 'Cz';
    eegObj.plot_data('timelock',cfg)
end

end