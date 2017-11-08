%% pdc_analysis_s3_std_perms
% run pdc analysis variations for a specific set of params with 20
% permutations

flag_tune = false;

paramsmini = [];
j = 1;
i = 1;
paramsmini(j).hemi = 'left';
paramsmini(j).params(i).gamma = 1e-5;
paramsmini(j).params(i).order = 4;
i = i+1;
j = j+1;

i = 1;
paramsmini(j).hemi = 'right';
paramsmini(j).params(i).gamma = 1e-5;
paramsmini(j).params(i).order = 5;
i = i+1;

nhemis = length(paramsmini);
for j=1:nhemis
    params = [];
    k=1;
    ngammas = length(paramsmini(j).params);
    
    for i=1:ngammas
        
        %% envelope
        params(k).downsample = 4;
        params(k).nfreqs = 1024*2;
        % fs = 2048, fs/2 = 1024 -> 1Hz bins
        params(k).nfreqscompute = 20*2+1; 
        % want 0-5Hz, 5*2+1, 
        params(k).metrics = {'diag'};%,'info'};
        params(k).ntrials = 20;
        if flag_tune
            params(k).order = 3:14; % for tuning
        else
            params(k).order = paramsmini(j).params(i).order;
        end
        params(k).lambda = 0.99;
        params(k).gamma = paramsmini(j).params(i).gamma;
        params(k).normalization = 'eachchannel';
        params(k).envelope = true;
        params(k).prepend_data = 'flipdata';
        params(k).permutations = true;
        params(k).npermutations = 100;
        params(k).tune_criteria_samples = [0.05 0.95];
        params(k).nresamples = 100;
        params(k).alpha = 0.05;
        params(k).null_mode = 'estimate_ind_channels';
        k = k+1;
    end
    
    %% mode
    if flag_tune
        mode = 'tune';
        flag_plot = false;
        flag_surrogate = false;
    else
        mode = 'run';
        flag_plot = true;
        flag_surrogate = false;
    end
    
    %% set up eeg
    
    stimulus = 'std';
    subject = 3;
    deviant_percent = 10;
    patch_options = {...
        'patchmodel','aal-coarse-19',...
        'patchoptions',{...
            'outer',true,...
            'cerebellum',false,...
            'hemisphere',paramsmini(j).hemi,...
            'flag_add_v1',true,...
            'flag_add_auditory',true...
            }...
        };
    
    out = eeg_processall_beta(...
        stimulus,subject,deviant_percent,patch_options);
    
    %% run variations
    pdc_analysis_variations(...
        out.file_sources,...
        out.file_sources_info,...
        params,...
        'outdir',out.outdir_sources,...
        'mode',mode,...
        'flag_plot_seed',false,...
        'flag_plot_seed_std',flag_plot,...
        'flag_plot_conn',flag_plot,...
        'flag_surrogate',flag_surrogate);
end
