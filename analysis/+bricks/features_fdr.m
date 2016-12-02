function features_fdr(files_in,files_out,opt)
%FEATURES_FDR selects features based on Fisher's discriminant ratio
%   FEATURES_FDR(files_in,files_out,opt) selects features based on Fisher's
%   discriminant ratio, choosing those that have the highest ratio.
%   formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string)
%       file name of feature matrix data, this should include fields:
%       samples, class_labels, feature_labels
%       see output of bricks.lattice_features_matrix
%   files_out (string)
%       file name of selected features and new feature_matrix
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   nfeatures (scalar, default = 1000)
%       number of features to select according to fisher's discriminant
%       ratio
%
%   Output
%   ------
%   output data contains the following fields
% 
%   feat_sel_fdr (vector)
%       indices of features selected by Fisher's discrinmant ratio
%   feature_labels (cell array) 
%       subset of feature labels selected by FDR
%   features (matrix)
%       subset of feature matrix selected by FDR with size [samples nfeatures]
%   class_labels (cell array)
%       class labels for each sample


p = inputParser;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@ischar);
addParameter(p,'nfeatures',1000,@isnumeric);
parse(p,files_in,files_out,opt{:});

% load the data
data_in = loadfile(files_in);

% filter out features using fisher's discriminant ratio
ratio = fishers_discriminant_ratio(data_in.samples,data_in.class_labels);
nfeatures = size(data_in.samples,2);

% sort features by ratio
temp = [ratio' (1:nfeatures)'];
ratio_sorted = sortrows(temp,-1);

% remove nans
ratio_sorted(isnan(ratio_sorted(:,1)),:) = [];

% select features by according to sorted ratios
nfeatures_left = size(ratio_sorted,1);
nfeatures = min(p.Results.nfeatures, nfeatures_left);
feat_sel_fdr = ratio_sorted(1:nfeatures,2);
features = data_in.samples(:,feat_sel_fdr);
feature_labels = data_in.feature_labels(feat_sel_fdr);

% save data
data = [];
data.feature_labels = feature_labels;
data.feat_sel_fdr = feat_sel_fdr;
data.features = features;
data.class_labels = data_in.class_labels;
save(files_out, 'data','-v7.3');

end