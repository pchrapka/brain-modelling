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
%   threshold_method (string, default = 'zero')
%       selects thresholding method, only needed if threshold ~= 'none'
%       options: zero, clamp
%
%       zero
%           coefficients that exceed the threshold are set to zero
%       clamp
%           coefficients that exceed the threshold are clamped to the
%           threshold
%
%   scaling (string, default = 'featurewise')
%       scaling mode for coefficients, 
%       options: none, threshold, featurewise
%
%       threshold
%           scales by the threshold parameter, so that coefficients range
%           between [-1 1]
%       featurewise
%           scales the range of each feature independently to [-1 1]
%   
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
addParameter(p,'scaling','featurewise',...
    @(x) any(validatestring(x,{'none','threshold','featurewise'})));
addParameter(p,'threshold_method','zero',...
    @(x) any(validatestring(x,{'zero','clamp'})));
addParameter(p,'threshold','none',@(x) (ischar(x) && isequal(x,'none')) || x > 0);
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
    switch p.Results.threshold_method
        case 'zero'
            % set large samples to zero
            samples(abs(samples) > p.Results.threshold) = 0;
        case 'clamp'
            % set large samples to the threshold
            samples(samples > p.Results.threshold) = p.Results.threshold;
            samples(samples < p.Results.threshold) = -p.Results.threshold;
    end
end

% scale samples to [-1,1]
switch p.Results.scaling
    case 'featurewise'
        % shift range to [0 max]
        samples_min = min(samples,1);
        samples = samples - repmat(samples_min,nsamples,1);
        % scale by max [0 1]
        samples_max = max(samples,1);
        samples = samples./repmat(samples_max,nsamples,1);
        % mult by 2 [0 2] and shift down [-1 1]
        samples = 2*samples - 1;
    case 'threshold'
        samples = samples/p.Results.threshold;
    case 'none'
        warning(['not scaling feature matrix\n'...
            'this could result in bad classification accuracy']);
end

% get all feature labels
lattice = loadfile(file_list{1});
feature_labels = lattice_feature_labels(size(lattice.Kf));
feature_labels = reshape(feature_labels,1,numel(lattice.Kf));

end