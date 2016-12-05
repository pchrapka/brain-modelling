function partition_data(files_in,files_out,opt)
%PARTITION_DATA partitions data into cross validation and test sets
%   PARTITION_DATA partitions data into cross validation and test sets.
%   formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (cell array)
%       file name of feature matrix, see output of bricks.feature_matrix
%   files_out (struct)
%   files_out.train (string)
%       file name of files selected for training set
%   files_out.test (string)
%       file name of files selected for test set
%   opt (cell array)
%       function options specified as name value pairs
%
%       Example:
%           opt = {'train', 100, 'test', 20};
%   
%   Parameters
%   ----------
%   train (integer, default = 100)
%       number of training samples to select for each label
%   test (integer, default = 20)
%       number of test samples to select for each label

p = inputParser;
p.StructExpand = false;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@(x) isfield(x,'train') & isfield(x,'test'));
addParameter(p,'train',100,@isnumeric);
addParameter(p,'test',20,@isnumeric);
parse(p,files_in,files_out,opt{:});

% load data
data = loadfile(files_in);

% count number of unique labels
data_labels = unique(data.class_labels);
nsets = length(data_labels);
nsamples_req = p.Results.train + p.Results.test;

test_data = [];
test_data.samples = [];
test_data.class_labels = [];
train_data = [];
train_data.samples = [];
train_data.class_labels = [];

for i=1:nsets
    % select samples for each set
    samples_set_idx = (data.class_labels == data_labels(i));
    samples_set = data.samples(samples_set_idx,:);
    
    % check that we have a minimum number of samples
    nsamples_in = size(samples_set,1);
    if nsamples_in < nsamples_req
        fprintf('got %d samples, require %d samples\n',nsamples_in, nsamples_req);
        error('not enough samples');
    end
    
    % randomly select nsamples_req from all samples
    idx_rand = randsample(nsamples_in, nsamples_req);
    samples_sel = samples_set(idx_rand,:);
    
    % partition the data
    c = cvpartition(nsamples_req,'HoldOut',p.Results.test/nsamples_req);
    
    % save test and train data
    test_data.samples = [test_data.samples; samples_sel(c.test,:)];
    test_data.class_labels = [test_data.class_labels; repmat(data_labels(i),p.Results.test,1)];
    train_data.samples = [train_data.samples; samples_sel(c.training,:)];
    train_data.class_labels = [train_data.class_labels; repmat(data_labels(i),p.Results.train,1)];
    
end

test_data.feature_labels = data.feature_labels;
train_data.feature_labels = data.feature_labels;

% save
save(files_out.test,'test_data','-v7.3');
save(files_out.train,'train_data','-v7.3');

end