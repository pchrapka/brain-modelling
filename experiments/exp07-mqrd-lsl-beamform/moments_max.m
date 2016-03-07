function moments = moments_max(datafile, varargin)
%MOMENTS_MAX returns moments with the largest power
%   MOMENTS_MAX(datafile) returns 10 moments with the largest power
%   
%   MOMENTS_MAX(datafile, 'N', value) returns N moments with the largest
%   power 
%
%   MOMENTS_MAX(datafile, 'NoiseThresh', value) returns moments with
%   power exceeding the noise power threshold
%
%   Input
%   -----
%   datafile (string)
%       file name of ft_sourceanalysis output
%
%   Parameters
%   'N', value (integer)
%       number of moments
%   'NoiseThresh', value (double)
%       noise power threshold
%
%   Output
%   ------
%   moments (cell array)
%       moments with the largest power

% parse inputs
p = inputParser;
addRequired(p,'datafile');
addParameter(p,'N',10,@isnumeric);
addParameter(p,'NoiseThresh',0,@isnumeric);
parse(p,datafile,varargin{:});

% load beamformed data
bfdata = ftb.util.loadvar(datafile);

% get power
sources_pow = bfdata.avg.pow;

% add idx to sources
idx_sources = 1:length(sources_pow);
sources_pow = [sources_pow idx_sources(:)];

% remove NaNs
sources_pow(isnan(sources_pow),:) = [];

% sort sources based on power
sources_pow = sortrows(sources_pow,-1);

% set up selection index
if p.Results.NoiseThresh > 0
    source_idx = sources_pow(:,1) > p.Results.NoiseThresh;
else
    source_idx = 1:p.Results.N;
end

% select top sources
moments = bfdata.avg.mom(sources_pow(source_idx,2));

end