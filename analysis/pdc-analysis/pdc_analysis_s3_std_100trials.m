%% pdc_analysis_s3_std_100trials
% run pdc analysis variations for a few gammas

hemis = {'both','left','right'};
% hemis = {'left','right'};
% hemis = {'both'};
% hemis = {'left'};
% hemis = {'right'};

% % optimized by visual inspection
gammas = [1e-5 1e-4 1e-3];
% orders = [5 3 3];

% gammas = [1e-5];
% orders = [5];

for j=1:length(hemis)
    params = [];
    k=1;
    
    for i=1:length(gammas)
        
        %% envelope
        params(k).downsample = 4;
        params(k).nfreqs = 512; % default 128
        params(k).metrics = {'diag'};%,'info'};
        params(k).ntrials = 100;
        %params(k).order = orders(i);
        params(k).order = 3:14; % for tuning
        params(k).lambda = 0.99;
        params(k).gamma = gammas(i);
        params(k).normalization = 'eachchannel';
        params(k).envelope = true;
        params(k).prepend_data = 'flipdata';
        params(k).permutations = false;%true;
        params(k).npermutations = 10;% 20;
        params(k).tune_criteria_samples = [0.05 0.95];
        params(k).nresamples = 100;
        params(k).alpha = 0.05;
        params(k).null_mode = 'estimate_ind_channels';
        k = k+1;
    end
    
    %% mode
    mode = 'tune';
    flag_plot = false;
    %mode = 'run;
    %flag_plot = true;
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