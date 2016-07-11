function plot_rc_feature_matrix_raw(data)
%PLOT_RC_FEATURE_MATRIX_RAW plots raw reflection coefficients from feature
%matrix
%   PLOT_RC_FEATURE_MATRIX_RAW(data) plots raw reflection coefficients from
%   feature matrix
%
%   Input
%   -----
%   data (struct)
%       data struct from bricks.features_matrix step, requires the
%       following fields:
%
%       feature_labels (cell array) 
%           feature labels
%       samples (matrix)
%           feature matrix with size [samples features]
%       class_labels (vector)
%           class labels for each sample
%
%   Parameters
%   ----------

[nsamples,nfeatures] = size(data.samples);

% precompute class indices
class_labels = unique(data.class_labels);
nclasses = length(class_labels);

class_idx = false(nsamples,length(class_labels));
for j=1:nclasses
    class_idx(:,j) = data.class_labels == class_labels(j);
end

% set up subplot settings
nrows = 1;
ncols = nclasses;

% clear figure
clf;

% separate based on class label
for j=1:nclasses

    idx_plot = j;
    
    subplot(nrows,ncols,idx_plot);
    imagesc(data.samples);
    colorbar;
    xlabel('Samples');
    ylabel('Features');

end

end