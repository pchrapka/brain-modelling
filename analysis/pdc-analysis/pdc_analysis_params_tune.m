%% pdc_analysis_params_tune

params = [];
k=1;

%% envelope, allchannels
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1 10];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1];
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'normerrortime';
% k = k+1;  

% best is 
%   lambda 0.99
%   gamma 1e-6

% % compare one set
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% % params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% params(k).lambda = 0.99;
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% % params(k).gamma = 1e-6;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'normerrortime';
% params(k).plot_orders = 6;
% k = k+1;  

% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-6;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;

% best order 12
% 
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-5;
% params(k).normalization = 'allchannels';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 11

%% envelope, eachchannel
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 1:15;
% params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1 10];
% % params(k).gamma = [1e-4 1e-3 1e-2 0.1 1];
% params(k).gamma = [1e-6 1e-5 1e-4 1e-3 1e-2 0.1];
% params(k).normalization = 'eachchannel';
% params(k).prepend_data = 'flipdata';
% params(k).envelope = true;
% params(k).plot_crit = 'normerrortime';
% k = k+1;  
% 
% % best is 
% %   lambda 0.99
% %   gamma 1e-6

% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-6;
% params(k).normalization = 'eachchannel';
% params(k).prepend_data = 'flipdata';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 13
% 
% params(k).downsample = 4;
% params(k).metrics = {'diag'};
% params(k).ntrials = 20;
% params(k).order = 2:15;
% params(k).lambda = 0.99;
% params(k).gamma = 1e-5;
% params(k).normalization = 'eachchannel';
% params(k).prepend_data = 'flipdata';
% params(k).envelope = true;
% params(k).plot_crit = 'ewaic';
% k = k+1;
% 
% % best order 11

%% envelope, eachchannel, flip data
%% new optimization

params(k).downsample = 4;
params(k).metrics = {'diag'};
params(k).ntrials = 20;
params(k).order = 3:14;
% params(k).lambda = [0.94 0.96 0.98 0.99 0.995];
params(k).lambda = 0.99;
params(k).gamma = [10^(-6) 10^(-3)];
params(k).normalization = 'eachchannel';
params(k).envelope = true;
params(k).prepend_data = 'flipdata';
params(k).nresamples = 100;
params(k).alpha = 0.05;
params(k).null_mode = 'estimate_ind_channels';
k = k+1;

%% mode
mode = 'tune';
flag_plot = false;
flag_bootstrap = false;

%% set up eeg

stimulus = 'std';
subject = 3;
deviant_percent = 10;
patch_options = {...
    'patchmodel','aal-coarse-19',...
    'patchoptions',{'outer',true,'cerebellum',false,'flag_add_auditory',true}};

out = eeg_processall_andrew(...
    stimulus,subject,deviant_percent,patch_options);

%% run variations
pdc_analysis_variations(...
    out.file_sources,...
    out.file_sources_info,...
    params,...
    'outdir',out.outdir_sources,...
    'mode',mode,...
    'flag_plot_seed',flag_plot,...
    'flag_plot_conn',flag_plot,...
    'flag_bootstrap',flag_bootstrap);