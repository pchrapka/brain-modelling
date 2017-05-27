function pdc_analysis_variations2(params,varargin)

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
    
    % TODO replace this
    pdc_view = pdc_analysis_create_view(...
        sources_data_file,...
        'envelope',params(i).envelope,... % TODO need envelope info for setting view frequency range
        'downsample',params(i).downsample);
    % TODO can i make envelope a top level parameter?
    % TODO add normalize and prepend to LatticeTrace?
            
    % NOTE params not required after this point
    % - envelope
    
    pdc_obj = PDCAnalysis(sources_filter_file,pdc_view,outdir);
    pdc_obj.ntrials = params(i).ntrials;
    pdc_obj.gamma = params(i).gamma;
    pdc_obj.lambda = params(i).lambda;
    pdc_obj.order = params(i).order;
    
    if isfield(params(i),'prepend_data')
        switch params(i).prepend_data
            case 'flipdata'
                % no warmup necessary if lattice_filter_prep_data prepends data
                pdc_obj.warmup = {};
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
        pdc_obj.tune_criteria_samples = [idx_start idx_end];
        
        pdc_obj.tune_plot_order = true;
        pdc_obj.tune();
        
    end
    
    if p.Results.flag_run
        
        % loop over metrics
        for j=1:length(params(i).metrics)
            
            %% pdc analysis
            if isfield(params(i),'prepend_data')
                switch params(i).prepend_data
                    case 'flipdata'
                        pdc_obj.filter_post_remove_samples = [1 nsamples/2];
                end
            end
            
            pdc_obj.downsample = params(i).downsample;
            pdc_obj.metric = params(i).metrics{j};
            pdc_obj.pdc();
            
            % add params for viewing
            params_plot_seed{1} = {'threshold',0.001};
            
            %% surrogate analysis
            if p.Results.flag_bootstrap
                pdc_obj.surrogate_nresamples = params(i).nresamples;
                pdc_obj.surrogate_alpha = params(i).alpha;
                pdc_obj.surrogate_null_mode = params(i).null_mode;
                pdc_obj.surrogate();
                
                params_plot_seed{2} = {...
                    'threshold_mode','significance',...
                    'tag',params(i).null_mode};
                
                % plot significance levels
                pdc_obj.plot_significance_level();
                
                % plot pdc for each surrogate data set
                plot_resample_pdc = false;
                if plot_resample_pdc
                    pdc_obj.plot_surrogate_pdc();
                end
                
            end
            
            %% plot seed
            if p.Results.flag_plot_seed
                for idx_param=1:length(params_plot_seed)
                    params_plot = [params_plot_seed{idx_param}, {'vertlines',[0 0.5]}];
                    pdc_obj.plot_seed(view_obj,params_plot{:});
                end
            end
            
            %% plot connectivity
            if p.Results.flag_plot_conn
                nsamples_real = floor(nsamples/params(i).downsample);
                idx_start = 0.25*nsamples_real;
                idx_end = nsamples_real;
                sample_idx = idx_start:idx_end;
                
                if isfield(params(i),'prepend_data')
                    switch params(i).prepend_data
                        case 'flipdata'
                            idx_start = 0.25*nsamples_real/2;
                            idx_end = nsamples_real/2;
                            sample_idx = idx_start:idx_end;
                    end
                end
                
                pdc_obj.view.plot_connectivity_matrix('samples',sample_idx);
                
                pdc_obj.view.save_plot('save',true,'engine','matlab');
                close(gcf);
            end
            
            
        end
    end
end

end