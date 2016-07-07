function plot_rc_feature_matrix_boxplot(data,varargin)
%PLOT_RC_FEATURE_MATRIX_BOXPLOT boxplot with reflection coefficients from
%feature matrix
%   PLOT_RC_FEATURE_MATRIX_BOXPLOT(data,...) boxplot with reflection
%   coefficients from feature matrix

[nsamples,nfeatures] = size(data.samples);

pattern = '.*t(\d+).*';
time_labels_all = cellfun(@(x) regexp(x, pattern, 'match'),...
    data.feature_labels, 'UniformOutput', true);
time_points_all = str2num(time_labels_all);
time_points = unique(time_points_all);
% time_labels = unique(time_labels_all);

% for i=1:ntime
%     % plot coefficients from one time step in plot
% end

end