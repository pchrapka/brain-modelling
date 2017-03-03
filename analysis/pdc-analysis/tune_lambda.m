%% tune_lambda

flag_plots = true;

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
% patches_type = 'aal';
% patches_type = 'aal-coarse-13';
patches_type = 'aal-coarse-19';

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
order_max = 6;
gamma = 1;

% tuning over lambdas
% lambdas = [0.95 0.96 0.97 0.98 0.99];
lambdas = [0.9:0.02:0.98 0.99];

%% set up filters
filters = {};
data_labels = {};
for k=1:length(lambdas)
    lambda = lambdas(k);
    data_labels{k} = sprintf('lambda %0.4f',lambda);
    filters{k} = MCMTLOCCD_TWL2(nchannels,order_max,ntrials,'lambda',lambda,'gamma',gamma);
end

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
% normtype = 'none';
normtype = 'allchannels';
envtype = true;
lf_files = lattice_filter_sources(filters, sources_file,...
    'normalization',normtype,...
    'envelope',envtype,...
    'tracefields',{'Kf','Kb','ferror','berrord'},...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

%% plot criteria for each gamma
crit_all = {'aic','ewaic','normtime'};
if flag_plots
%     crit = 'ewaic';
    crit = 'normtime';
    for k=1:length(lf_files)
        view_lf = ViewLatticeFilter(lf_files{k});
        view_lf.compute(crit_all);
        view_lf.plot_criteria_vs_order_vs_time('criteria',crit,'orders',1:order_max);
    end
end

%% plot criteria for best order across gamma
if flag_plots
    order_best = [1 2 3];
%     crit = 'ewaic';
    crit = 'normtime';
    
    view_lf = ViewLatticeFilter(lf_files,'labels',data_labels);
    view_lf.compute(crit_all);
    view_lf.plot_criteria_vs_order_vs_time(...
        'criteria',crit,...
        'orders',order_best,...
        'file_list',1:length(lf_files));
end
