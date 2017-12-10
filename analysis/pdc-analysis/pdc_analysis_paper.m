%% pdc_analysis_paper
% run pdc analysis variations for the paper

exp_template = [];
exp_template.mode = ''; % tune
exp_template.hemi = '';
exp_template.subject = 3;
exp_template.params.downsample = 4;
exp_template.params.nfreqs = 1024*2; % fs = 2048, fs/2 = 1024 -> 1Hz bins
exp_template.params.nfreqscompute = 20*2+1; % want 0-20Hz, 20*2+1,
exp_template.params.metrics = {'diag'};%,'info'};

exp_template.params.lambda = 0.99;
exp_template.params.ntrials = 0;
exp_template.params.order = 0;
exp_template.params.gamma = 0;

exp_template.params.normalization = 'eachchannel';
exp_template.params.envelope = true;
exp_template.params.prepend_data = 'flipdata';

exp_template.params.permutations = false;
exp_template.params.npermutations = 1;

exp_template.params.tune_criteria_samples = [0.05 0.95];
exp_template.params.nresamples = 100;
exp_template.params.alpha = 0.05;
exp_template.params.null_mode = 'estimate_ind_channels';

experiments = {};
k = 1;

%% envelope, H=20
% left, surrogate ind, plot tf, plot conn
experiments{k} = exp_template;
experiments{k}.mode = 'run';
experiments{k}.hemi = 'left';
experiments{k}.params.ntrials = 20;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 4;
% experiments{k}.params.permutation_idx = 3;
experiments{k}.params.gamma = 1e-4;
experiments{k}.params.order = 5;
experiments{k}.params.null_mode = 'estimate_ind_channels';
experiments{k}.flag_plot_seed = true;
experiments{k}.flag_plot_conn = true;
experiments{k}.flag_surrogate = true;
k = k+1;

% left, surrogate ns
experiments{k} = experiments{k-1};
experiments{k}.mode = 'run';
experiments{k}.params.null_mode = 'estimate_stationary_ns';
k = k+1;

% left, perms, plot std
experiments{k} = experiments{k-1};
experiments{k}.mode = 'run';
experiments{k}.params.permutations = true;
experiments{k}.params.npermutations = 100;
experiments{k}.flag_plot_seed = false;
experiments{k}.flag_plot_seed_std = true;
experiments{k}.flag_plot_conn = false;
experiments{k}.flag_surrogate = false;
k = k+1;

% right, plot tf, plot conn
experiments{k} = exp_template;
experiments{k}.mode = 'run';
experiments{k}.hemi = 'right';
experiments{k}.params.ntrials = 20;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 5;
% experiments{k}.params.permutation_idx = 3;
experiments{k}.params.gamma = 1e-4;
experiments{k}.params.order = 5;
experiments{k}.flag_plot_seed = true;
experiments{k}.flag_plot_conn = true;
experiments{k}.flag_surrogate = false;
k = k+1;

%% envelope, H=100

% % left, surrogate ind, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'left';
% experiments{k}.params.ntrials = 100;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 5;
% experiments{k}.params.null_mode = 'estimate_ind_channels';
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = true;
% k = k+1;
% 
% % left, surrogate ns
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.null_mode = 'estimate_stationary_ns';
% k = k+1;
% 
% % left, perms, plot std
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.permutations = true;
% experiments{k}.params.npermutations = 100;
% experiments{k}.flag_plot_seed = false;
% experiments{k}.flag_plot_seed_std = true;
% experiments{k}.flag_plot_conn = false;
% experiments{k}.flag_surrogate = false;
% k = k+1;
% 
% % right, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'right';
% experiments{k}.params.ntrials = 100;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 5;
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = false;
% k = k+1;

%% envelope, subject 5, H=100
exp_template.subject = 5;

% % left, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'left';
% experiments{k}.params.ntrials = 100;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 5;
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = false;
% k = k+1;
% 
% % right, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'right';
% experiments{k}.params.ntrials = 100;
% experiments{k}.params.gamma = 1e-5;
% experiments{k}.params.order = 5;
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = false;
% k = k+1;

%% no envelope, H=20
exp_template.subject = 3;
exp_template.params.nfreqscompute = 40*2+1; % want 0-40Hz
exp_template.params.envelope = false;

% % left, surrogate ind, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'left';
% experiments{k}.params.ntrials = 20;
% % experiments{k}.params.gamma = 1e-5;
% % experiments{k}.params.order = 6;
% experiments{k}.params.gamma = 1e-4;
% experiments{k}.params.order = 5;
% experiments{k}.params.null_mode = 'estimate_ind_channels';
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = true;
% k = k+1;
% 
% % left, surrogate ns
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.null_mode = 'estimate_stationary_ns';
% k = k+1;
% 
% % left, perms, plot std
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.permutations = true;
% experiments{k}.params.npermutations = 100;
% experiments{k}.flag_plot_seed = false;
% experiments{k}.flag_plot_seed_std = true;
% experiments{k}.flag_plot_conn = false;
% experiments{k}.flag_surrogate = false;
% k = k+1;

%% no envelope, H=100

% % left, surrogate ind, plot tf, plot conn
% experiments{k} = exp_template;
% experiments{k}.mode = 'run';
% experiments{k}.hemi = 'left';
% experiments{k}.params.ntrials = 100;
% % experiments{k}.params.gamma = 1e-5;
% % experiments{k}.params.order = 6;
% experiments{k}.params.gamma = 1e-4;
% experiments{k}.params.order = 6;
% experiments{k}.params.null_mode = 'estimate_ind_channels';
% experiments{k}.flag_plot_seed = true;
% experiments{k}.flag_plot_conn = true;
% experiments{k}.flag_surrogate = true;
% k = k+1;
% 
% % left, surrogate ns
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.null_mode = 'estimate_stationary_ns';
% k = k+1;
% 
% % left, perms, plot std
% experiments{k} = experiments{k-1};
% experiments{k}.mode = 'run';
% experiments{k}.params.permutations = true;
% experiments{k}.params.npermutations = 100;
% experiments{k}.flag_plot_seed = false;
% experiments{k}.flag_plot_seed_std = true;
% experiments{k}.flag_plot_conn = false;
% experiments{k}.flag_surrogate = false;
% k = k+1;


%% run experiments
nexps = length(experiments);
for j=1:nexps
    if experiments{j}.params.gamma == 0
        error('missing gamma for experiment %d',j);
    end
    if experiments{j}.params.ntrials == 0
        error('missing ntrials for experiment %d',j);
    end
    if isempty(experiments{j}.hemi)
        error('missing hemi for experiment %d',j);
    end
    
    switch experiments{j}.mode
        case 'tune'
            experiments{j}.params.order = 3:14; % for tuning
            % no plots while tunning
            experiments{j}.flag_plot_seed = false;
            experiments{j}.flag_plot_seed_std = false;
            experiments{j}.flag_plot_conn = false;
            % no surrogate while tuning
            experiments{j}.flag_surrogate = false;
        case 'run'
            if experiments{j}.params.order == 0
                error('missing order for experiment %d',j);
            end
            % set default flags
            if ~isfield(experiments{j}, 'flag_plot_seed')
                experiments{j}.flag_plot_seed = true;
            end
            if ~isfield(experiments{j}, 'flag_plot_seed_std')
                experiments{j}.flag_plot_seed_std = false;
            end
            if ~isfield(experiments{j}, 'flag_plot_conn')
                experiments{j}.flag_plot_conn = true;
            end
            if ~isfield(experiments{j}, 'flag_surrogate')
                experiments{j}.flag_surrogate = false;
            end
        otherwise
            error('unknown mode');
    end
    
    %% set up eeg
    stimulus = 'std';
    subject = experiments{j}.subject;
    deviant_percent = 10;
    patch_options = {...
        'patchmodel','aal-coarse-19',...
        'patchoptions',{...
            'outer',true,...
            'cerebellum',false,...
            'hemisphere',experiments{j}.hemi,...
            'flag_add_v1',true,...
            'flag_add_auditory',true...
            }...
        };
    
    out = eeg_processall_beta(...
        stimulus,subject,deviant_percent,patch_options);
    
    %% run variations
    try
        pdc_analysis_variations(...
            out.file_sources,...
            out.file_sources_info,...
            experiments{j}.params,...
            'outdir',out.outdir_sources,...
            'mode',experiments{j}.mode,...
            'flag_plot_seed',experiments{j}.flag_plot_seed,...
            'flag_plot_seed_std',experiments{j}.flag_plot_seed_std,...
            'flag_plot_conn',experiments{j}.flag_plot_conn,...
            'flag_surrogate',experiments{j}.flag_surrogate);
        
        
        experiments{j}.error.flag = false;
        experiments{j}.error.exception = [];
    catch me
        experiments{j}.error.flag = true;
        experiments{j}.error.exception = me;
    end
end

fprintf('\nexperiment errors\n');
fprintf('-----------------\n');
for j=1:nexps
    if experiments{j}.error.flag
        fprintf('experiment %d\n', j)
        fprintf(getReport(experiments{j}.error.exception));
    end
end
