function [samples,class_labels,feature_labels] = lattice_features_matrix(file_list,varargin)
%LATTICE_FEATURES_MATRIX creates feature matrix from samples
%   [samples,class_labels,feature_labels] =
%   LATTICE_FEATURES_MATRIX(file_list,...) creates feature matrix from
%   samples. formatted for use with PSOM pipeline
%
%   Input
%   -----
%   file_list (string)
%       list of sample fles to process, see output of
%       bricks.partition_files or bricks.lattice_filter_sources
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   threshold (scalar, default = 'none')
%       threshold for lattice coefficient values, samples containing
%       coefficents above this value are set to zero
%
%       NOTE better classification accuracy results if the same threshold
%       is used for both train and test sets
%
%   Output
%   ------
%   output data contains the following fields
% 
%   feature_labels (cell array) 
%       feature labels
%   samples (matrix)
%       feature matrix with size [samples features]
%   class_labels (vector)
%       class labels for each sample

p = inputParser;
addRequired(p,'file_list',@iscell);
addParameter(p,'threshold','none',@(x) x > 0);
parse(p,file_list,varargin{:});

% get dimensions
nsamples = length(file_list);
lattice = loadfile(file_list{1});
nfeatures = numel(lattice.Kf);

% allocate mem
samples = zeros(nsamples, nfeatures);
class_labels = zeros(nsamples,1);
% bad_samples = [];

% loop over data files
parfor i=1:nsamples
    %fprintf('samples %d\n',i);
    % load lattice filtered data
    lattice = loadfile(file_list{i});
    % reshape the data into a vector
    samples(i,:) = reshape(lattice.Kf,1,nfeatures);
    
    % something like a label map
    switch lattice.label
        case 'std'
            class_labels(i) = 1;
        case 'odd'
            class_labels(i) = 0;
    end
    
end

% threshold bad samples
if ~isequal(p.Results.threshold,'none')
    % zero large samples to zero
    samples(abs(samples) > p.Results.threshold) = 0;
end

% scale samples to [-1,1]
if ~isequal(p.Results.threshold,'none')
    samples = samples/p.Results.threshold;
else
    warning(['not scaling feature matrix\n'...
        'this could result in bad classification accuracy']);
end

% get all feature labels
lattice = loadfile(file_list{1});
feature_labels = lattice_feature_labels(size(lattice.Kf));
feature_labels = reshape(feature_labels,1,numel(lattice.Kf));

end