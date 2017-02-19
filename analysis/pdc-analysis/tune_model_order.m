%% tune_model_order

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
atlas_name = 'aal';
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

%% set lattice options
% lf = loadfile(lf_file);
% patch_labels = lf.filter_label(lf.inside);
% patch_labels = cellfun(@(x) strrep(x,'_',' '),...
%     patch_labels,'UniformOutput',false);
% npatch_labels = length(patch_labels);
% patch_centroids = lf.patch_centroid(lf.inside,:);
% clear lf;

nchannels = npatch_labels;
ntrials = 20;
lambda = 0.99;
gamma = 1;

% tuning over model order
order_est = 1:12;

filters = cell(length(order_est),1);

for k=1:length(order_est)
    filters{k} = MCMTLOCCD_TWL2(nchannels,order_est(k),ntrials,'lambda',lambda,'gamma',gamma);
end

%% lattice filter

verbosity = 2;
lf_files = lattice_filter_sources(filters, sources_file,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% plot estimation error vs model order

