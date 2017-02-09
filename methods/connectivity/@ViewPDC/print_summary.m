function print_summary(obj,varargin)
%
%   Parameters
%   ----------
%   nprint (integer, default = 20)
%       number of entries to print
%   outdir (string)
%       output directory for summary data
%       by default uses output directory set in ViewPDC.outdir, can be
%       overriden here with:
%       1. 'data' - same directory where data is located
%       2. any regular path
%   save (logical, default = false)
%       flag to save summary to data file

p = inputParser();
addParameter(p,'nprint',20,@isnumeric);
addParameter(p,'save',false,@islogical);
addParameter(p,'outdir','',@ischar);
parse(p,varargin{:});

out = obj.get_summary('save',p.Results.save,'outdir',p.Results.outdir);

% set up labels
nchannels = out.dims(2);
if isempty(obj.labels)
    labels = cell(nchannels,1);
    for i=1:nchannels
        labels{i} = sprintf('%d',i);
    end
else
    if ~isequal(length(obj.labels),nchannels)
        error('missing some labels');
    end
    labels = obj.labels;
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