%% tune_gamma

flag_plots = true;

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
patches_type = 'aal';
% patches_type = 'aal-coarse-13';

[pipeline,outdir] = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patches_type);

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
gammas = [1e-4 1e-3 1e-2 0.1 1 10];

%% set up filters
filters = {};
data_labels = {};
for k=1:length(gammas)
    gamma = gammas(k);
    data_labels{k} = sprintf('gamma %.3e',gamma);
    filters{k} = MCMTLOCCD_TWL2(nchannels,order_max,ntrials,'lambda',lambda,'gamma',gamma);
end

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
% normtype = 'none';
normtype = 'allchannels';
lf_files = lattice_filter_sources(filters, sources_file,...
    'normalization',normtype,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% plot criteria for each gamma
crit_all = {'aic','ewaic','normtime'};
if flag_plots
    for k=1:length(lf_files)
        view_lf = ViewLatticeFilter(lf_files{k});
        view_lf.compute(crit_all);
        view_lf.plot_criteria_vs_order_vs_time('criteria','ewaic','orders',1:order_max);
    end
end

%% plot criteria for best order across gamma
if flag_plots
    order_best = [2 3];
    %crit = 'ewaic';
    crit = 'normtime';
    
    view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
    view_lf.compute(crit_all);
    view_lf.plot_criteria_vs_order_vs_time(...
        'criteria',crit,...
        'orders',order_best,...
        'file_list',1:length(lf_files));
end

