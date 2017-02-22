function [pipeline,outdir] = eeg_preprocessing_std_s3_10()

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patches_type = 'aal';
% patches_type = 'aal-coarse-13';

%% output dir

[data_file,data_name,~] = get_data_andrew(subject,deviant_percent);

% dataset = data_file;
data_name2 = sprintf('%s-%s',stimulus,data_name);
analysis_dir = fullfile(get_project_dir(),'analysis','pdc-analysis');
outdir = fullfile(analysis_dir,'output',data_name2);

%% preprocess data for beamforming
eeg_preprocessing_andrew(subject,deviant_percent,stimulus,...
    'patches',patches_type,...
    'outdir',outdir);

%% beamform sources
pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%% compute induced sources
eeg_file = fullfile(outdir,'ft_rejectartifact.mat');
lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

eeg_induced(sources_file, eeg_file, lf_file, 'outdir',outdir);

end