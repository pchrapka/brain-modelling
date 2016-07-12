function train_test_common(files_in,files_out,opt)
%TRAIN_TEST_COMMON trains and tests an SVM on a common feature set
%   TRAIN_TEST_COMMON
%
%   Input
%   -----
%   files_in (struct)
%   files_in.validated (string)
%       file name of validated features, see output of
%       bricks.features_validate
%   files_in.test
%       file name of files selected for test set
%   files_in.train
%       file name of files selected for training set
%       file names of file lists of lattice filter output, see output of
%       bricks.lattice_filter_sources
%   files_out (string)
%       output file name, contains training predictions, test predictions
%       and common feature set
%   opt (cell array)
%       function options specified as name value pairs
%
%       Example:
%           opt = {'KernelFunction', 'rbf'};
%   
%   Parameters
%   ----------
%   KernelFunction (string, default = 'rbf')
%       kernel function
%   BoxConstraintParams (vector, default = exp(-2:2))
%       parameters for BoxConstraint grid search
%   KernelScaleParams (vector, default = exp(-2:2))
%       parameters for KernelScaleParams grid search
%   nfeatures_common (integer, default = 10)
%       number of common features to select from validated features
%
%   Output
%   ------
%   output data contains the following fiels
%   predictions
%       predictions from test daata
%   class_labels
%       true class labels of test data
%   feat_common
%       indices of common features

p = inputParser;
p.StructExpand = false;
addRequired(p,'files_in',@(x)...
    isfield(x,'train') & isfield(x,'test') &...
    isfield(x,'validated') & isfield(x,'fdr'));
addRequired(p,'files_out',@ischar);
addParameter(p,'KernelFunction','rbf',@ischar);
addParameter(p,'BoxConstraintParams',exp(-2:2),@isvector);
addParameter(p,'KernelScaleParams',exp(-2:2),@isvector);
addParameter(p,'nfeatures_common',10,@isnumeric);
addParameter(p,'verbosity',0,@isnumeric);
parse(p,files_in,files_out,opt{:});

% load data
train_data = loadfile(files_in.train);
test_data = loadfile(files_in.test);
validated_data = loadfile(files_in.validated);
fdr_data = loadfile(files_in.fdr);

% filter train and test data by fdr indices
train_data = features_filter(train_data, fdr_data.feat_sel_fdr);
test_data = features_filter(test_data, fdr_data.feat_sel_fdr);

% determine common features from validation data
[feat_common_idx, ~] = features_select_common(validated_data.feat_sel, p.Results.nfeatures_common);

% filter train and test data by common features
train_data = features_filter(train_data, feat_common_idx);
test_data = features_filter(test_data, feat_common_idx);

% TODO should i discretize reflection coefs??

% setup SVM
model = SVM(train_data.samples, train_data.class_labels, 'implementation','libsvm');

% optimize box and scale
params = model.optimize(...
    'KernelFunction',p.Results.KernelFunction,...
    'box', p.Results.BoxConstraintParams,...
    'scale', p.Results.KernelScaleParams,...
    'verbosity',p.Results.verbosity);
% train SVM
model.train(...
    'KernelFunction',p.Results.KernelFunction,...
    'BoxConstraint',params.BoxConstraint,...
    'KernelScale',params.KernelScale);

predictions_train = model.predict(train_dat.samples);
if isempty(predictions_train)
    error('something went wrong with the prediction step');
end

% test SVM
predictions = model.predict(test_data.samples);
if isempty(predictions)
    error('something went wrong with the prediction step');
end

% set up save struct
data = [];
data.predictions = predictions;
data.class_labels = test_data.class_labels;
data.feat_common = feat_common_idx;
data.predictions_train = predictions_train;
data.class_labels_train = train_data.class_labels;

save(p.Results.files_out,'data');

end