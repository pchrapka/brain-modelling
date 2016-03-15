function [out] = check_metric(cfg, metric)
%CHECK_METRIC checks the metric for a match to cfg
%
%   cfg specifies query parameters for the metric of interest
%   cfg.name
%       (string, required), name of the metric
%   cfg.(metric-specific-fields)
%       (optional) arbitrary field specifying additional information about
%       the metric, this is optional and dependent on the desired metric
%
%   metric has the following structure
%       metric.name 
%           (required)
%       metric.output 
%           (required)
%       metric.(metric-specific-field) 
%           (optional), these fields contain extra information pertaining
%           to the metric, typically configuration parameters

% Check the metric name
pattern =  regexptranslate('escape', cfg.name);
out = regexp(metric.name, ['^' pattern '$']);

if isempty(out)
    out = false;
    return;
end

% Check other metric specific fields
names = fieldnames(cfg);
for i=1:length(names)
    field = names{i};
    field_val = cfg.(field);
    
    % Return if the field doesn't even exist
    if ~isfield(metric, field)
        out = false;
        return;
    end
    
    % Check the field, based on the type of the value in the field
    if ischar(field_val)
        if ischar(metric.(field))
            pattern =  regexptranslate('escape', field_val);
            out = regexp(metric.(field), ['^' pattern '$']);
        else
            out = false;
            return
        end
    else
        out = isequaln(metric.(field), field_val);
    end
    
    % Check the result
    if isempty(out)
        out = false;
        return;
    else
        out = logical(out);
        if ~out
            % Return if we've discovered a non-match
            return;
        end
    end
    
end

end