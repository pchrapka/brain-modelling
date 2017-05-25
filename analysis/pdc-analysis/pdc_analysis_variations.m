function pdc_analysis_variations(params,varargin)

p = inputParser();
addRequired(p,'params',@isstruct);
addParameter(p,'flag_run',true,@islogical);
addParameter(p,'flag_tune',false,@islogical);
addParameter(p,'flag_bootstrap',false,@islogical);
addParameter(p,'flag_plot_seed',false,@islogical);
addParameter(p,'flag_plot_conn',false,@islogical);
parse(p,params,varargin{:});


for i=1:length(params)
    
    subject = 3;
    deviant_percent = 10;
    
    [pipeline,outdirbase] = eeg_processall_andrew(...
        params(i).stimulus,subject,deviant_percent,params(i).patch_type);
    
    % separate following output based on patch model
    outdir = fullfile(outdirbase,params(i).patch_type);
    
    %% prep source data
    eeg_file = fullfile(outdirbase,'fthelpers.ft_phaselocked.mat');
    params_func = struct2namevalue(params(i),...
        'fields', {'normalization','envelope','patch_type','prepend_data'});
    [sources_data_file,sources_filter_file] = lattice_filter_prep_data(...
        pipeline,...
        eeg_file,...
        'outdir', outdir,...
        'ntrials_max', 100,...
        params_func{:});
    
    data = loadfile(sources_data_file);
    nsamples = data.nsamples;
    clear data;
    
    % set default options to warmup
    run_options = {...
        'warmup_noise',true,...
        'warmup_data',true};
    
    if isfield(params(i),'prepend_data')
        switch params(i).prepend_data
            case 'flipdata'
                % no warmup necessary if lattice_filter_prep_data prepends data
                run_options = {...
                    'warmup_noise',false,...
                    'warmup_data', false};
        end
    end
    
    %% tune parameters
    if p.Results.flag_tune
        
        tune_file = strrep(sources_filter_file,'.mat','-tuning.mat');
        if ~exist(tune_file,'file') || isfresh(tune_file,sources_filter_file)
            if exist(tune_file,'file')
                delete(tune_file);
            end
            copyfile(sources_filter_file, tune_file);
        end
        
        switch params(i).stimulus
            case 'std'
                idx_start = floor(nsamples*0.05);
                idx_end = ceil(nsamples*0.95);
            case 'std-prestim1'
                nsamples_trial = floor(nsamples/4);
                nsamples_rest = nsamples - nsamples_trial;
                idx_start = floor(nsamples_rest*0.05) + nsamples_trial;
                idx_end = ceil(nsamples_rest*0.95) + nsamples_trial;
            otherwise
                error('missing start and end for %s',params(i).stimulus);
        end
        
        if isfield(params(i),'prepend_data')
            switch params(i).prepend_data
                case 'flipdata'
                    if isequal(params(i).stimulus,'std-prestim1')
                        error('flipdata is not necessary for std-prestim1');
                    end
                    nsamples_half = nsamples/2;
                    %idx_start = floor(nsamples_half*0.05) + nsamples_half;
                    idx_start = floor(nsamples_half*0.5) + nsamples_half;
                    idx_end = ceil(nsamples_half*0.95) + nsamples_half;
            end
        end
        criteria_samples = [idx_start idx_end];
        
        flag_plot_params = false;
        tune_lattice_filter_parameters(...
            tune_file,...
            outdir,...
            'plot_gamma',flag_plot_params,...
            'plot_lambda',flag_plot_params,...
            'plot_order',true,...
            'filter','MCMTLOCCD_TWL4',...
            'ntrials',params(i).ntrials,...
            'gamma',params(i).gamma,...
            'lambda',params(i).lambda,...
            'order',params(i).order,...
            'run_options',run_options,...
            'criteria_samples',criteria_samples);
        
    end
    
    if p.Results.flag_run
        % copy params
        params2 = params(i);
        
        % loop over metrics
        for j=1:length(params(i).metrics)
            
            %% compute RC with lattice filter
            % select lf params
            params_func = struct2namevalue(params2, 'fields', {'ntrials','order','lambda','gamma'});
            
            lf_files = lattice_filter_sources(...
                sources_filter_file,...
                'outdir',outdir,...
                'run_options',run_options,...
                'tracefields', {'Kf','Kb','Rf','ferror','berrord'},...
                'verbosity',0,...
                params_func{:});
            % added Rf for info criteria
            % added ferror for bootstrap
            
            if isfield(params(i),'prepend_data')
                switch params(i).prepend_data
                    case 'flipdata'
                        lf_files = lattice_filter_remove_data(lf_files,[1 nsamples/2]);
                end
            end
            
            %% compute pdc
            downsample_by = 4;
            pdc_params = {...
                'metric',params(i).metrics{j},...
                'downsample',downsample_by,...
                };
            pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);
            
            %% view set up
            % select pdc view params
%             params_func = struct2namevalue(params2,'fields',{'patch_type','envelope'});
            
            % create the ViewPDC obj
            view_obj = pdc_analysis_create_view(...
                pdc_files{1},...
                sources_data_file,...
                'envelope',params(i).envelope,...
                'downsample',downsample_by);
            
            % add params for viewing
            params_plot_seed{1} = {'threshold',0.001};
            
            %% bootstrap
            if p.Results.flag_bootstrap
                params_func = struct2namevalue(params2,...
                    'fields', {'nresamples','alpha','null_mode'});
                [pdc_sig_file, pdc_resample_files] = pdc_bootstrap(...
                    lf_files{1},...
                    sources_data_file,...
                    'run_options',run_options,...
                    params_func{:},...
                    'pdc_params',pdc_params);
                
                % add significance threshold data
                view_obj.pdc_sig_file = pdc_sig_file;
                
                params_plot_seed{2} = {...
                    'threshold_mode','significance',...
                    'tag',params2.null_mode};
                
                % bootstrap checks
                check_bt_data = false;
                if check_bt_data
                    %pdc_bootstrap_check(pdc_sig_file, sources_mini_file);
                    resample_idx = 1;
                    pdc_bootstrap_check_resample(pdc_sig_file,resample_idx,...
                        params_func{:},...
                        'eeg_file',eeg_file,'leadfield_file',leadfield_file);
                end
                
                % plot significance level
                view_sig_obj = pdc_analysis_create_view(...
                    pdc_sig_file,...
                    sources_data_file,...
                    'envelope',params(i).envelope,...
                    'downsample',downsample_by);
                
                pdc_plot_seed_threshold(view_sig_obj);
                
                % plot pdc for each surrogate data set
                plot_resample_pdc = false;
                if plot_resample_pdc
                    max_files = min(5,length(pdc_resample_files));
                    for k=1:max_files
                        view_obj_resample = pdc_analysis_create_view(...
                            pdc_resample_files{k},...
                            sources_data_file,...
                            'envelope',params(i).envelope,...
                            'downsample',downsample_by);
                        
                        pdc_plot_seed_threshold(view_obj_resample);
                    end
                end
                
            end
            
            %% plot seed
            if p.Results.flag_plot_seed
                nchannels = length(view_obj.info.label);
                directions = {'outgoing','incoming'};
                for direc=1:length(directions)
                    for ch=1:nchannels
                        for idx_param=1:length(params_plot_seed)
                            params_plot_seed_cur = params_plot_seed{idx_param};
                            
                            created = view_obj.plot_seed(ch,...
                                'direction',directions{direc},...
                                params_plot_seed_cur{:},...
                                'vertlines',[0 0.5]);
                            
                            if created
                                view_obj.save_plot('save',true,'engine','matlab');
                            end
                            close(gcf);
                        end
                    end
                end
            end
            
            %% plot connectivity
            if p.Results.flag_plot_conn
                idx_start = 0.25*nsamples;
                idx_end = nsamples;
                sample_idx = idx_start:idx_end;
                
                if isfield(params(i),'prepend_data')
                    switch params(i).prepend_data
                        case 'flipdata'
                            idx_start = 0.25*nsamples/2;
                            idx_end = nsamples/2;
                            sample_idx = idx_start:idx_end;
                    end
                end
                
                view_obj.plot_connectivity_matrix('samples',sample_idx);
                
                view_obj.save_plot('save',true,'engine','matlab');
                close(gcf);
            end
            
            
        end
    end
end

end