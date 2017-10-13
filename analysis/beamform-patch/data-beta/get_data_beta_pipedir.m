function pipedir = get_data_beta_pipedir()

% get the data folder
[data_file,~,~] = get_data_beta(6,10);
[data_dir ,~,~] = fileparts(data_file);

% set up pipeline folder
pipedir = fullfile(data_dir,'output','ftb');

end
