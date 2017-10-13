%% beta_elec_choose_subjects

%% standard trials
% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(4,10,'std'),...
%     get_data_beta_pipedir()); 
% % big forehead

% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(2,10,'std'),...
%     get_data_beta_pipedir()); 
% % big hair?

% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(3,10,'std'),...
%     get_data_beta_pipedir()); 
% % small back of head, but decent

pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(5,10,'std'),...
    get_data_beta_pipedir()); 
% % better than 3

% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(6,10,'std'),...
%     get_data_beta_pipedir()); 
% % a bit large, would need a projection

% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(8,10,'std'),...
%     get_data_beta_pipedir()); 
% % shifted forward

% pipeline = build_pipeline_beamformerpatch(paramsbf_sd_beta(10,10,'std'),...
%     get_data_beta_pipedir()); 
% % extra side space

% so 3,5 or 6
pipeline.process();
