%% run_bf_patch_coma22

%% all std and dev
pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22('std'),get_data_coma_pipedir());
pipeline.process();

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22('odd'),get_data_coma_pipedir());
pipeline.process();

%% only consecutive std and dev pairs
pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22_consec('std'),get_data_coma_pipedir());
pipeline.process();

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22_consec('odd'),get_data_coma_pipedir());
pipeline.process();