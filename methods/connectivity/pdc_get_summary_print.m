function pdc_get_summary_print(data,varargin)
%   Input
%   -----
%   data (struct/string)
%       pdc output data struct or file
%
%   Parameters
%   ----------
%   w (vector, default = [0 0.5])
%       normalized frequency range
%   fs (number,default= 1)
%       sampling frequency

p = inputParser();
addRequired(p,'data',@(x) ischar(x) || istruct(x));
addParameter(p,'nprint',20,@isnumeric);
addParameter(p,'labels',{},@iscell);
addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2));
addParameter(p,'fs',1,@isnumeric);
parse(p,data,varargin{:});

out = pdc_get_summary(data,'fs',p.Results.fs,'w',p.Results.w);

% set up labels
nchannels = out.dims(2);
if isempty(p.Results.labels)
    labels = cell(nchannels,1);
    for i=1:nchannels
        labels{i} = sprintf('%d',i);
    end
else
    if ~isequal(length(p.Results.labels),nchannels)
        error('missing some labels');
    end
    labels = p.Results.labels;
end

% print
nprint = min([p.Results.nprint length(out.idx_sorted)]);
for i=1:nprint
    idx = out.idx_sorted(i);
    fprintf('rank: %3d',i);
    fprintf('\tmag: %g\n', out.mag(idx));
    fprintf('\tj: %s', labels{out.idxj(idx)});
    fprintf('--> i: %s\n', labels{out.idxi(idx)});
end

end