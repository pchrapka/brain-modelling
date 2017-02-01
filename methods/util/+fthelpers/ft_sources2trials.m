function out = ft_sources2trials(cfg,sources,eeg,varargin)

p = inputParser();
addRequired(p,'cfg',@(x) isstruct(x) || isempty(x));
addRequired(p,'sources',@(x) isstruct || ischar(x));
addRequired(p,'eeg',@(x) isstruct(x) || ischar(x));
addParameter(p,'labels',{},@iscell);
parse(p,cfg,sources,eeg,varargin{:});

% check inputs
if ~isempty(cfg)
    warning('cfg is not used');
end

if ischar(sources)
    sources = loadfile(sources);
end

if ischar(eeg)
    eeg = loadfile(eeg);
end

fields_required = {'fsample','trialinfo','sampleinfo'};
for i=1:length(fields_required)
    if ~isfield(eeg,fields_required{i})
        error('missing field %s',fields_required{i});
    end
end

% convert sources
ntrials = length(sources.trial);

out = copyfields(eeg,[],{'fsample','trialinfo','sampleinfo'});
for i=1:ntrials
    out.trial{i} = cell2mat(sources.trial(i).mom(sources.inside));
    out.time{i} = sources.time;
end

% add labels
nsources = size(sources.trial(1),1);
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