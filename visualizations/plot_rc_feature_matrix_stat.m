function plot_rc_feature_matrix_stat(data,varargin)
%PLOT_RC_FEATURE_MATRIX_STAT plots a statistic of reflection coefficients from
%feature matrix
%   PLOT_RC_FEATURE_MATRIX_STAT(data,...) plots a statistic of reflection
%   coefficients from feature matrix
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
%   stat (string, default = 'mean')
%       type of stat to compute, options: mean, std


p = inputParser();
addParameter(p,'stat','mean',@(x) any(validatestring(x,{'mean','std'})));
p.parse(varargin{:});

[nsamples,nfeatures] = size(data.samples);

% parse feature labels
[time_points_all,order_all,c1_all,c2_all] = parse_rc_feature_labels(data.feature_labels);

% get unique values and lengths
orders = unique(order_all);
norders = length(orders);

time_points = unique(time_points_all);
ntime = length(time_points);

channels = unique(c1_all);
nchannels = length(channels);

% set up iterator
orders = reshape(orders,1,numel(orders));

% precompute class indices
class_labels = unique(data.class_labels);
nclasses = length(class_labels);

class_idx = false(nsamples,length(class_labels));
for j=1:nclasses
    class_idx(:,j) = data.class_labels == class_labels(j);
end

% set up subplot settings
nrows = norders;
ncols = nclasses;

% clear figure
clf;

% separate based on class label
for j=1:nclasses
    
    % compute stat for the current class
    switch p.Results.stat
        case 'mean'
            data_stat = mean(data.samples(class_idx(:,j),:),1);
        case 'std'
            data_stat = std(data.samples(class_idx(:,j),:),1);
        otherwise
            error('unknown stat %s',p.Results.stat);
    end
    data_stat = reshape(data_stat, ntime, norders, nchannels, nchannels);
    
    % plot each order separately
    for k=orders
        idx_plot = (k-1)*ncols + j;
        
        subplot(nrows,ncols,idx_plot);
        data_plot = squeeze(data_stat(:,k,:,:));
        data_plot = reshape(data_plot,ntime,numel(data_plot)/ntime)';
        imagesc(data_plot);
        colorbar;
        
        ylabel(sprintf('P %d',k));
        if idx_plot == 1
            title(sprintf('%s',p.Results.stat));
        end
    end
end

end