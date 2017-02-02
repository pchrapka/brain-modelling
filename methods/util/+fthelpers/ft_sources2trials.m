function out = ft_sources2trials(cfg,varargin)
%FT_SOURCES2TRIALS converts sources to trial based struct
%   data = FT_SOURCES2TRIALS(cfg,...) converts sources to trial based
%   struct
%
%   Input
%   -----
%   cfg (struct)
%       struct with the following fields
%   cfg.sources (string/struct)
%       sources data file or struct
%   cfg.eeg (string/struct)
%       eeg data file or struct
%
%   Parameters
%   ----------
%   labels (cell array)
%       source labels

p = inputParser();
addRequired(p,'cfg',@isstruct);
addParameter(p,'labels',{},@iscell);
parse(p,cfg,varargin{:});

%% check inputs
fields = {'sources','eeg'};
for i=1:length(fields)
    field = fields{i};
    
    if ~isfield(cfg,field)
        error('missing %s',field);
    end
    
    if ~isstruct(cfg.(field)) && ~ischar(cfg.(field))
        error('bad type for %s, expecting struct or char',field);
    end
end

%% load data
if ischar(cfg.sources)
    sources = loadfile(cfg.sources);
else
    sources = cfg.sources;
    cfg.sources = [];
end

if ischar(cfg.eeg)
    eeg = loadfile(cfg.eeg);
else
    eeg = cfg.eeg;
    cfg.eeg = [];
end

%% create data struct
% fields_required = {'fsample','trialinfo','sampleinfo'};
fields_required = {'fsample','sampleinfo'};
for i=1:length(fields_required)
    if ~isfield(eeg,fields_required{i})
        error('missing field %s',fields_required{i});
    end
end

%% convert sources
ntrials = length(sources.trial);

out = copyfields(eeg,[],{'fsample','trialinfo','sampleinfo'});
for i=1:ntrials
    out.trial{i} = cell2mat(sources.trial(i).mom(sources.inside));
    out.time{i} = sources.time;
end

%% add labels
nsources = size(out.trial{1},1);
if isempty(p.Results.labels)
    out.label = cell(nsources,1);
else
    if length(p.Results.labels) ~= nsources
        error('labels do not match. %d labels, %d sources',...
            length(p.Results.labels), nsources);
    else
        out.label = p.Results.labels;
    end
end

end