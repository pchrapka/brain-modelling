function config_add(field, value)
%CONFIG_ADD Saves a value in the specified field to a config file

% Set up config file name
config_file = 'config.mat';

% Check if it exists
if exist(config_file, 'file')
    % Load the file if it exists
    din = load(config_file);
    config = din.config;
    config.(field) = value;
    % Save
    save(config_file, 'config');
else
    % Create a new config file
    config = [];
    config.(field) = value;
    % Save
    save(config_file, 'config');
end

end