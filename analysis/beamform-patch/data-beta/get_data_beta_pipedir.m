function pipedir = get_data_beta_pipedir()

% get the data folder
params_data = data_beta_config();

% set up pipeline folder
pipedir = fullfile(params_data.data_dir,'output','ftb');

end
