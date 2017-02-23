%% tune_model_order

[pipeline,outdir] = eeg_preprocessing_std_s3_10();
lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

%% set lattice options
lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);
clear lf;

nchannels = npatch_labels;
ntrials = 20;
lambda = 0.99;
gamma = 1;

% tuning over model order
order_est = 1:14;

filters = {};
k = 1;

order_max = max(order_est);
filters{k} = MCMTLOCCD_TWL2(nchannels,order_max,ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 2;
lf_files = lattice_filter_sources(filters, sources_file,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% set up view lattice
view_lf = ViewLatticeFilter(lf_files{1});

%% plot model order vs estimation error
view_lf.plot_esterror_vs_order('orders',1:norder_est);
view_lf.plot_esterror_vs_order_vs_time('orders',1:norder_est);
view_lf.plot_criteria_vs_order_vs_time('criteria','aic','orders',1:norder_est);
view_lf.plot_criteria_vs_order_vs_time('criteria','sc','orders',1:norder_est);