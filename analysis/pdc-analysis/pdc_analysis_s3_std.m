%% pdc_analysis_params_gamma
% run pdc analysis variations for a few gammas

params = [];
k=1;

hemis = {'both','left','right'};

% gammas = [1e-3 1e-2 1e-1];

% optimized by visual inspection
gammas = [1e-5 1e-4 1e-3];
orders = [5 3 3];

for j=1:length(hemis)
    
    for i=1:length(gammas)
        %     %% no envelope
        %     params(k).downsample = 4;
        %     params(k).metrics = {'diag','info'};
        %     params(k).ntrials = 20;
        %     params(k).order = 11;
        %     params(k).lambda = 0.99;
        %     params(k).gamma = gammas(i);
        %     params(k).normalization = 'eachchannel';
        %     params(k).envelope = false;
        %     params(k).prepend_data = 'flipdata';
        %     params(k).nresamples = 100;
        %     params(k).alpha = 0.05;
        %     params(k).null_mode = 'estimate_ind_channels';
        %     k = k+1;
        
        %% envelope
        params(k).downsample = 4;
        params(k).metrics = {'diag'};%,'info'};
        params(k).ntrials = 20;
        params(k).order = orders(i);
        %params(k).order = 3:14; % for tuning
        params(k).lambda = 0.99;
        params(k).gamma = gammas(i);
        params(k).normalization = 'eachchannel';
        params(k).envelope = true;
        params(k).prepend_data = 'flipdata';
        params(k).nresamples = 100;
        params(k).alpha = 0.05;
        params(k).null_mode = 'estimate_ind_channels';
        k = k+1;
    end
    
    %% mode
    mode = 'run';
    flag_plot = true;
    flag_bootstrap = false;
    
    %% set up eeg
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    patch_options = {...
        'patchmodel','aal-coarse-19',...
        'patchoptions',{...
            'outer',true,...
            'cerebellum',false,...
            'hemisphere',hemis{j},...
            'flag_add_v1',true,...
            'flag_add_auditory',true...
            }...
        };
    
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
end