%% tune_gamma

flag_plots = false;

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
order_max = 6;

% tuning over gammas
gammas = [0.001 0.1 1 10];
data_labels = {'gamma 0.001','gamma 0.1','gamma 1','gamma 10'};

%% set up filters
filters = {};
for k=1:length(gammas)
    gamma = gammas(k);
    filters{k} = MCMTLOCCD_TWL2(nchannels,order_max,ntrials,'lambda',lambda,'gamma',gamma);
end

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
lf_files = lattice_filter_sources(filters, sources_file,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% plot criteria for each gamma
if flag_plots
    for k=1:length(lf_files)
        view_lf = ViewLatticeFilter(lf_files{k});
        view_lf.compute({'ewaic'});
        view_lf.plot_criteria_vs_order_vs_time('criteria','ewaic','orders',1:order_max);
    end
end

%% plot criteria for best order across gamma
if flag_plots
    order_best = 'adjust this';
    
    view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
    view_lf.compute({'ewaic'});
    view_lf.plot_criteria_vs_order_vs_time(...
        'criteria','ewaic',...
        'orders',order_best,...
        'file_idx',1:length(lf_files));
end

