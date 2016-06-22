function out = discretize_reflection_coefs(data, varargin)
%DISCRETIZE discretizes reflection coefficient values into bins
%   OUT = DISCRETIZE(DATA, BINS, ...) discretizes reflection coefficients
%   into bins. each element then becomes an integer between [1, BINS]. all
%   columns are evaluted based on a global min and max.
%
%   data (matrix)
%       feature matrix, where each column represents a feature and each row
%       represents a segment
%   
%   Parameters
%   ----------
%   bins (integer, default = 10)
%       number of bins to use for the data, for feature selection 10 bins
%       is a good choice (Brown2012, "Conditional Likelihood Maximisation:
%       A Unifying Framework for Information Theoretic Feature Selection")
%   min (integer, default = -1)
%       minimum reflection coefficient value
%   max (integer, default = 1)
%       maximum reflection coefficient value

p = inputParser;
addRequired(p,'data',@ismatrix);
addParameter(p,'bins',10,@isnumeric);
addParameter(p,'min',-1,@isnumeric);
addParameter(p,'max',1,@isnumeric);
parse(p,data,varargin{:});

[nsamples, nfeatures] = size(data);

% Set the min, max and range
data_min = p.Results.min*ones(1,nfeatures);
data_max = p.Results.max*ones(1,nfeatures);
data_range = data_max - data_min;

% Force values outside of range to min and max
data(data > p.Results.max) = p.Results.max;
data(data < p.Results.min) = p.Results.min;

% Subtract the min for each feature
out = data - repmat(data_min, nsamples, 1);
% Normalize each feature so that the range is 0-1
out = out./repmat(data_range, nsamples, 1);
% Multiply by number of bins for the range to be 0-bins
out = out*p.Results.bins;
% Round each value up to the closest integer
out = ceil(out);

end