function [feat_common, freq] = features_select_common(feat_sel, nfeatures)
%SELECT_COMMON selects common features from LOO feature selection
%   [FEAT_COMMON, FREQ] = SELECT_COMMON(FEAT_SEL, NFEATURES) selects common
%   features from different feature selection runs
%
%   Input
%   -----
%   feat_sel (matrix)
%       matrix of selected feature indices, [features runs]
%   nfeatures (integer)
%       number of common features to be selected
%
%   Output
%   ------
%   feat_common (vector)
%       indices of common features
%   freq (vector)
%       frequency of occurrence of each feature

% Count the occurrence of each feature
[feat_count, feat_idx] = hist(feat_sel(:), unique(feat_sel));

% Sort by highest count
data = [feat_idx(:) feat_count(:)];
data = sortrows(data, -2);

% Return the top nfeatures
feat_common = data(1:nfeatures,1);
freq = data(1:nfeatures,2);

end