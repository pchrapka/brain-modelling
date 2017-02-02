function out = ft_induced(cfg,varargin)
%FT_INDUCED computes induced EEG 
%   FT_INDUCED(cfg,data) computes induced EEG 
%
%   Input
%   -----
%   cfg (struct)
%       struct with the following fields
%   cfg.phaselocked (string)
%       phaselocked data file, where only trial is the average
%   cfg.trials (string)
%       trials data file
%
%   Parameters
%   ----------

p = inputParser();
addRequired(p,'cfg',@(x) isstruct(x) || isempty(x));
parse(p,cfg,varargin{:});

%% check inputs
fields = {'trials','phaselocked'};
for i=1:length(fields)
    field = fields{i};
    
    if ~isfield(cfg,field)
        error('missing %s',field);
    end
    
    if ~ischar(cfg.(field))
        error('bad type for %s, expecting char',field);
    end
end

%% load data
if ischar(cfg.trials)
    data = loadfile(cfg.trials);
end

if ischar(cfg.phaselocked)
    data_phaselocked = loadfile(cfg.phaselocked);
end

if length(data_phaselocked.trial) > 1
    error('phase locked data should only have 1 trial');
end

%% compute induced
out = data;
ntrials = length(data.trial);
for i=1:ntrials
    out.trial{i} = data.trial{i} - data_phaselocked.trial{1};
end

end