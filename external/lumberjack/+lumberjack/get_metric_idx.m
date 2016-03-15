function [idx] = get_metric_idx(cfg, data)
%GET_METRIC_IDX finds a metric in the metric cell array
%
%   data must contain a field 'metrics' which is a cell array of metric
%   structs. each metric struct has the following structure
%       metric.name 
%           (required)
%       metric.output 
%           (required)
%       metric.(metric-specific-field) 
%           (optional), these fields contain extra information pertaining
%           to the metric, typically configuration parameters
%
%   cfg specifies query parameters for the metric of interest
%   cfg.name
%       (string, required), name of the metric
%   cfg.(metric-specific-fields)
%       (optional) arbitrary field specifying additional information about
%       the metric, this is optional and dependent on the desired metric

% Check each metric result
output = cellfun(@(x) lumberjack.check_metric(cfg, x), data.metrics);

% Get the idx
idx = find(output);

end