%% exp31_bf_explore

stimulus = 'std';
subject = 6;
deviant_percent = 10;
% patches_type = 'aal';
patches_type = 'aal-coarse-13';

[~,data_name,~] = get_data_andrew(subject,deviant_percent);

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%%

% eeg = loadfile(pipeline.steps{end-1}.preprocessed);
sources = loadfile(pipeline.steps{end}.sourceanalysis);

% convert source analysis to EEG data structure
data = [];
