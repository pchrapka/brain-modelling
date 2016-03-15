function [value, status] = config_get(field)
%CONFIG_GET Get the value in the specified field from the config file
%   [value, status] = config_get(field)
%
%   status
%       1   if the field is found
%       0   if the field is not found
%   value
%       value of the field

% Set up config file name
config_file = 'config.mat';
status = 0;
value = [];

% Check if it exists
if exist(config_file, 'file')
    % Load the file if it exists
    din = load(config_file);
    config = din.config;
    if isfield(config, field);
        value = config.(field);
        status = 1;
    else
        fprintf('field: %s not found\n', field);
    end
end

end