%% pdc_analysis_main

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patches_type = 'aal';
% patches_type = 'aal-coarse-13';

%% preprocess data for beamforming
eeg_preprocessing(subject,deviant_percent,stimulus,'patches',patches_type);

%% beamform sources
pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%% compute induced sources
eeg_induced(subject,deviant_percent,stimulus,'patches',patches_type);

%% lattice filter

%% compute PDC