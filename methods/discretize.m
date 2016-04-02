function out = discretize(data, bins)
%DISCRETIZE discretizes feature values into bins
%   OUT = DISCRETIZE(DATA, BINS) discretizes each feature into bins. Each
%   element then becomes an integer between [1, BINS]
%
%   data (matrix)
%       feature matrix, where each column represents a feature and each row
%       represents a segment
%   bins (integer)
%       number of bins to use for the data, for feature selection 10 bins
%       is a good choice (Brown2012, "Conditional Likelihood Maximisation:
%       A Unifying Framework for Information Theoretic Feature Selection")

[nsegments, ~] = size(data);

% Calculate the range and min for each feature
data_range = range(data);
data_min = min(data);

% Subtract the min for each feature
out = data - repmat(data_min, nsegments, 1);
% Normalize each feature so that the range is 0-1
out = out./repmat(data_range, nsegments, 1);
% Multiply by number of bins for the range to be 0-bins
out = out*bins;
% Round each value up to the closest integer
out = ceil(out);

end