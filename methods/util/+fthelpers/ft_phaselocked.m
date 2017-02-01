function out = ft_phaselocked(cfg,data,varargin)

p = inputParser();
addRequired(p,'cfg',@(x) isstruct(x) || isempty(x));
addRequired(p,'data',@(x) isstruct || ischar(x));
parse(p,cfg,data,varargin{:});

% check inputs
if ~isempty(cfg)
    warning('cfg is not used');
end

if ischar(data)
    data = loadfile(data);
end

avg = zeros(size(data.trial{1}));
for i=1:ntrials
    avg = avg + data.trial{i};
end
avg = avg/ntrials;

out = copyfields(data,[],{'fsamples','label'});
out.trial{1} = avg;
out.time{1} = data.time{1};
out.trialinfo = data.trialinfo(1);
out.sampleinfo = data.sampleinfo(1,:);

end