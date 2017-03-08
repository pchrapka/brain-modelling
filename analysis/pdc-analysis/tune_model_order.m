%% tune_model_order

flag_plots = true;

stimulus = 'std';
subject = 3; 
deviant_percent = 10;
% patches_type = 'aal';
% patches_type = 'aal-coarse-13';
% patches_type = 'aal-coarse-19';
% patches_type = 'aal-coarse-19-plus2';
patches_type = 'aal-coarse-19-outer-plus2';

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
gamma = 1;

% tuning over model order
order_est = 1:14;

filters = {};
k = 1;

order_max = max(order_est);
filters{k} = MCMTLOCCD_TWL4(nchannels,order_max,ntrials,'lambda',lambda,'gamma',gamma);
k = k+1;

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

%% set up view lattice
if flag_plots
    view_lf = ViewLatticeFilter(lf_files{1});
    crit_time = {'ewaic','ewsc','normtime'};
    crit_single = {'aic','sc','norm'};
    view_lf.compute([crit_time crit_single]);
    
    % plot order vs estimation error
    view_lf.plot_criteria_vs_order_vs_time('criteria','ewaic','orders',order_est);
%     view_lf.plot_criteria_vs_order_vs_time('criteria','ewsc','orders',order_est);
%     view_lf.plot_criteria_vs_order_vs_time('criteria','normtime','orders',order_est);
    
%     view_lf.plot_criteria_vs_order('criteria','aic','orders',order_est);
%     view_lf.plot_criteria_vs_order('criteria','sc','orders',order_est);
%     view_lf.plot_criteria_vs_order('criteria','norm','orders',order_est); 
end
