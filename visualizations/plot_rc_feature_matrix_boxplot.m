function plot_rc_feature_matrix_boxplot(data,varargin)
%PLOT_RC_FEATURE_MATRIX_BOXPLOT boxplot with reflection coefficients from
%feature matrix
%   PLOT_RC_FEATURE_MATRIX_BOXPLOT(data,...) boxplot with reflection
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
%   interactive (logcial, default = true)
%       selects interactive mode for displaying data at each time step

p = inputParser();
addParameter(p,'interactive',true,@islogical);
p.parse(varargin{:});

[nsamples,nfeatures] = size(data.samples);

time_points_all = zeros(nfeatures,1);
order_all = zeros(nfeatures,1);
short_labels = cell(nfeatures,1);
for i=1:nfeatures
    % figure number of time points, filter orders, and use channels as
    % short labels
    pattern = '.*t(\d+).*p(\d+)-(c.*)';
    results = regexp(data.feature_labels{i}, pattern, 'tokens');
    time_points_all(i) = str2double(results{1}{1});
    
    % similarly for filter orders
    order_all(i) = str2double(results{1}{2});
    short_labels{i} = results{1}{3};
end

orders = unique(order_all);
orders = reshape(orders,1,numel(orders));
norders = length(orders);
time_points = unique(time_points_all);
time_points = reshape(time_points,1,numel(time_points));
% time points will be sorted


% precompute class indices
class_labels = unique(data.class_labels);
nclasses = length(class_labels);
class_idx = false(nsamples,length(class_labels));
for j=1:nclasses
    class_idx(:,j) = data.class_labels == class_labels(j);
end

colors = 'br';
spacing = 0.3;

% set up subplot settings
nrows = norders;
ncols = nclasses;

for i=time_points
    
    % get coefficients for current time point
    idx_coef = (time_points_all == i);
    
    % clear figure
    clf;
    
    % separate based on class label
    for j=1:nclasses
        
        for k=orders
            % get coefficients for current order
            idx_order = (order_all == k);
            
            idx = idx_coef & idx_order;
            idx_plot = (k-1)*ncols + j;
            
            box_data = data.samples(:,idx);
            nboxes = size(box_data,2);
            
            spacing_temp = (j-1)*spacing;
            positions = (1 + spacing_temp):1:(nboxes + spacing_temp);
            
            % plot coefficients from one time step in plot
            if j==nclasses && k==norders
                subplot(nrows,ncols,idx_plot);
                boxplot(box_data(class_idx(:,j),:),'Labels',short_labels(idx),...
                    'plotstyle','compact','colors',colors(j),'positions', positions);
                hold on;
            else
                empty_labels = cell(nboxes,1);
                [empty_labels{:}] = deal('');
                
                subplot(nrows,ncols,idx_plot);
                boxplot(box_data(class_idx(:,j),:),'Labels',empty_labels,...
                    'plotstyle','compact','colors',colors(j),'positions', positions);
                hold on;
            end
            
            ylabel(sprintf('P %d',k));
            if idx_plot == 1
                title(sprintf('Time %d',i));
            end
        end
    end
    
    if p.Results.interactive
        prompt = 'Next iteration? (q to quit)';
        result = input(prompt,'s');
        if isequal(result,'q')
            break;
        end
    end
end

end