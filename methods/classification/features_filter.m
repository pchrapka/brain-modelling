function data = features_filter(data,idx)
%FEATURES_FILTER filter features based on a feature index
%   data = FEATURES_FILTER(data,idx) filter features based on a feature
%   index
%
%   Input
%   -----
%   data (struct)
%       struct containing the fields samples and feature_labels
%   data.samples (matrix)
%       feature matrix of size [samples features]
%   data.feature_labels (cell array)
%       list of feature labels
%   idx (logical vector)

data.samples = data.samples(:,idx);
data.feature_labels = data.feature_labels(idx);

end