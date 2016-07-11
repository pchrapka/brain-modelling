function plot_rc_feature_matrix_diff(data,varargin)
%PLOT_RC_FEATURE_MATRIX_DIFF plots difference of a measure of
%reflection coefficients from feature matrix
%   PLOT_RC_FEATURE_MATRIX_DIFF(data,...) plots difference of a measure
%   of reflection coefficients from feature matrix
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
%   Parameter
%   ---------
%   measure (string, default = 'mean')
%       options: mean, median


p = inputParser();
addParameter(p,'measure','mean',@(x) any(validatestring(x,{'mean','median'})));
p.parse(varargin{:});

[nsamples,nfeatures] = size(data.samples);

% precompute class indices
class_labels = unique(data.class_labels);
nclasses = length(class_labels);

if nclasses > 2
    error('this doesn''t make sense');
end

class_idx = false(nsamples,length(class_labels));
data_measure = zeros(nclasses,nfeatures);
for j=1:nclasses
    class_idx(:,j) = data.class_labels == class_labels(j);
    switch p.Results.measure
        case 'mean'
            data_measure(j,:) = mean(data.samples(class_idx(:,j),:),1);
        case 'median'
            data_measure(j,:) = median(data.samples(class_idx(:,j),:),1);
    end
end

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

data_diff = data_measure(1,:) - data_measure(2,:);

% set up subplot settings
nrows = norders;
ncols = 1;

% clear figure
clf;

data_diff = reshape(data_diff, ntime, norders, nchannels, nchannels);

% plot each order separately
for k=orders
    idx_plot = k;
    
    subplot(nrows,ncols,idx_plot);
    data_plot = squeeze(data_diff(:,k,:,:));
    data_plot = reshape(data_plot,ntime,numel(data_plot)/ntime)';
    imagesc(data_plot);
    colorbar;
    
    ylabel(sprintf('P %d',k));
    if idx_plot == 1
        title(sprintf('diff %s',p.Results.measure));
    end
    
    if k == orders(end)
        xlabel('Time');
    else
        set(gca,'xticklabel',[]);
        set(gca,'yticklabel',[]);
    end
end

end