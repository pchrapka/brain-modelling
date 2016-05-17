function lattice_features_matrix(files_in,files_out,opt)
%LATTICE_FEATURES_MATRIX creates feature matrix from samples
%   LATTICE_FEATURES_MATRIX creates feature matrix from samples. it filters
%   features based on Fisher's discriminant ratio, choosing those that have
%   the highest ratio. formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (cell array)
%       file names of samples to process, see also
%       bricks.lattice_filter_sources
%   files_out (string)
%       file name of feature matrix
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   threshold (scalar, default = 'none')
%       threshold for lattice coefficient values, samples containing
%       coefficents above this value are removed
%   features_fdr (scalar, default = 1000)
%       number of features to select according to fisher's discriminant
%       ratio
%
%   Output
%   ------
%   output data contains the following fields
% 
%   feature_labels (cell array) 
%       feature labels
%   feat_sel_fdr (vector)
%       indices of features selected by Fisher's discrinmant ratio
%   features (matrix)
%       feature matrix with size [samples features], only those selected by
%       Fisher's discriminant ratio
%   class_labels (cell array)
%       class labels for each sample

p = inputParser;
addRequired(p,'files_in',@iscell);
addRequired(p,'files_out',@ischar);
addParameter(p,'threshold','none');
addParameter(p,'features_fdr',1000,@isnumeric);
parse(p,files_in,files_out,opt{:});

% get dimensions
nsamples = length(files_in);
lattice = ftb.util.loadvar(files_in{1});
nfeatures = numel(lattice.Kf);

% allocate mem
samples = zeros(nsamples, nfeatures);
class_labels = zeros(nsamples,1);
bad_samples = [];

% loop over data files
for i=1:nsamples
    % load lattice filtered data
    lattice = ftb.util.loadvar(files_in{i});
    % reshape the data into a vector
    samples(i,:) = reshape(lattice.Kf,1,nfeatures);
    
    % something like a label map
    switch lattice.label
        case 'std'
            class_labels(i) = 1;
        case 'odd'
            class_labels(i) = 0;
    end
    
    % % check if we have bad samples
    % NOTE Can remove every sample, this is not a good approach
    %if ~isequal(p.Results.threshold,'none')
    %    if any(abs(samples(i,:)) > p.Results.threshold)
    %        bad_samples(end+1,1) = i;
    %    end
    %end
end

% % remove bad samples
%samples(bad_samples,:) = [];
%class_labels(bad_samples,:) = [];

% get all feature labels
feature_labels = lattice_feature_labels(size(lattice.Kf));
feature_labels = reshape(feature_labels,1,numel(lattice.Kf));

% filter out features using fisher's discriminant ratio
ratio = fishers_discriminant_ratio(samples,class_labels);
temp = [ratio' (1:nfeatures)'];
ratio_sorted = sortrows(temp,-1);
feat_sel_fdr = ratio_sorted(1:p.Results.features_fdr,2);
features = samples(:,feat_sel_fdr);
feature_labels = feature_labels{feat_sel_fdr};

% save data
data = [];
data.feature_labels = feature_labels;
data.feat_sel_fdr = feat_sel_fdr;
data.features = features;
data.class_labels = class_labels;
save(files_out, 'data');

end