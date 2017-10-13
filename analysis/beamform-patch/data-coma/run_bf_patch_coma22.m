%% run_bf_patch_coma22

%% all std and dev
pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22('std'));
pipeline.process();

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22('odd'));
pipeline.process();

%% only consecutive std and dev pairs
pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22_consec('std'));
pipeline.process();

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_coma22_consec('odd'));
pipeline.process();