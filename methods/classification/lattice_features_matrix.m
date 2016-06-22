function [samples,class_labels,feature_labels] = lattice_features_matrix(file_list)
%LATTICE_FEATURES_MATRIX creates feature matrix from samples
%   LATTICE_FEATURES_MATRIX creates feature matrix from samples. formatted
%   for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string)
%       file name of list of samples to process, see output of
%       bricks.partition_files or bricks.lattice_filter_sources
%   files_out (string)
%       output file name
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   DEPRECATED? threshold (scalar, default = 'none')
%       threshold for lattice coefficient values, samples containing
%       coefficents above this value are removed
%
%   Output
%   ------
%   output data contains the following fields
% 
%   feature_labels (cell array) 
%       feature labels
%   samples (matrix)
%       feature matrix with size [samples features]
%   class_labels (cell array)
%       class labels for each sample

p = inputParser;
addRequired(p,'file_list',@iscell);
%addParameter(p,'threshold','none');
parse(p,file_list);

% get dimensions
nsamples = length(file_list);
lattice = ftb.util.loadvar(file_list{1});
nfeatures = numel(lattice.Kf);

% allocate mem
samples = zeros(nsamples, nfeatures);
class_labels = zeros(nsamples,1);
bad_samples = [];

% loop over data files
for i=1:nsamples
    % load lattice filtered data
    lattice = ftb.util.loadvar(file_list{i});
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

end