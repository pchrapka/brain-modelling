function pipedir = get_data_andrew_pipeline()

% get the data folder
[data_file,~,~] = get_data_andrew(6,10);
[data_dir ,~,~] = fileparts(data_file);

% set up pipeline folder
pipedir = fullfile(data_dir,'output','ftb');

end