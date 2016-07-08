function plot_rc_feature_matrix_boxplot(data,varargin)
%PLOT_RC_FEATURE_MATRIX_BOXPLOT boxplot with reflection coefficients from
%feature matrix
%   PLOT_RC_FEATURE_MATRIX_BOXPLOT(data,...) boxplot with reflection
%   coefficients from feature matrix

p = inputParser();
addParameter(p,'interactive',true,@islogical);
p.parse(varargin{:});

[nsamples,nfeatures] = size(data.samples);

% figure number of time points
pattern = '.*t(\d+).*';
time_labels_all = cellfun(@(x) regexp(x, pattern, 'tokens'),...
    data.feature_labels, 'UniformOutput', true);
time_points_all = cellfun(@(x) str2double(x{1}),...
    time_labels_all, 'UniformOutput', true);
time_points = unique(time_points_all);
% time points will be sorted

% precompute class indices
class_labels = unique(data.class_labels);
class_idx = false(nsamples,length(class_labels));
for j=1:length(class_labels)
    class_idx(:,j) = data.class_labels == class_labels(j);
end

colors = 'br';
spacing = 0.3;

for i=time_points
    
    % get coefficients for current time point
    %pattern = sprintf('.*t%d.*',i);
    %idx_coef = cellfun(@(x) ~isempty(regexp(x, pattern, 'tokens')),...
    %    data.feature_labels, 'UniformOutput', true);
    idx_coef = (time_points_all == i);
    
    box_data = data.samples(:,idx_coef);
    nboxes = size(box_data,2);
    
    % clear figure
    clf;
    
    % separate based on class label
    for j=1:length(class_labels)
        spacing_temp = (j-1)*spacing;
        positions = (1 + spacing_temp):1:(nboxes + spacing_temp);
        
        % plot coefficients from one time step in plot
        if j==length(class_labels)
            boxplot(box_data(class_idx(:,j),:),'Labels',data.feature_labels(idx_coef),...
                'plotstyle','compact','colors',colors(j),'positions', positions);
            hold on;
        else
            empty_labels = cell(nboxes,1);
            [empty_labels{:}] = deal('');
            boxplot(box_data(class_idx(:,j),:),'Labels',empty_labels,...
                'plotstyle','compact','colors',colors(j),'positions', positions);
            hold on;
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