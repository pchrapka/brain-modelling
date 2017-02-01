function out = ft_induced(cfg,data,data_phaselocked,varargin)

p = inputParser();
addRequired(p,'cfg',@(x) isstruct(x) || isempty(x));
addRequired(p,'data',@(x) isstruct || ischar(x));
addRequired(p,'data_phaselocked',@(x) isstruct || ischar(x));
parse(p,cfg,data,data_phaselocked,varargin{:});

% check inputs
if ~isempty(cfg)
    warning('cfg is not used');
end

if ischar(data)
    data = loadfile(data);
end

if ischar(data_phaselocked)
    data_phaselocked = loadfile(data_phaselocked);
end

out = data;
for i=1:ntrials
    out.trial{i} = data.trial{i} - data_phaselocked.trial{1};
end

end