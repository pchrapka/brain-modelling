function pipedir = get_data_coma_pipedir()

% get the data folder
[data_dir,~,~] = get_coma_data(22);

% set up pipeline folder
pipedir = fullfile(data_dir,'output','ftb');

end