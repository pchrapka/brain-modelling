function pdc_analysis_variations(file_sources, file_sources_info, params,varargin)

p = inputParser();
addRequired(p,'file_sources',@ischar);
addRequired(p,'file_sources_info',@ischar);
addRequired(p,'params',@isstruct);
addParameter(p,'outdir','pdc-analysis',@ischar);
addParameter(p,'mode','run',@(x) any(validatestring(x,{'run','tune'})));
addParameter(p,'flag_bootstrap',false,@islogical);
addParameter(p,'flag_plot_seed',false,@islogical);
addParameter(p,'flag_plot_seed_var',false,@islogical);
addParameter(p,'flag_plot_seed_std',false,@islogical);
addParameter(p,'flag_plot_conn',false,@islogical);
parse(p,file_sources,file_sources_info,params,varargin{:});

% figure out mode of operation
flag_tune = false;
flag_run = false;

switch p.Results.mode
    case 'tune'
        flag_tune = true;
    case 'run'
        flag_run = true;
    otherwise
        error('unknown mode %s',p.Results.mode);
end


for i=1:length(params)
    
    % get some data info
    data = loadfile(file_sources_info);
    nchannels = data.nchannels;
    nsamples = data.nsamples;
    clear data;
    
    %% set up objects
    
    % set up lattice filter analysis
    lf_obj = LatticeFilterAnalysis(...
        file_sources,'outdir',p.Results.outdir);
    lf_obj.filter_func = 'MCMTLOCCD_TWL4';
    lf_obj.ntrials_max = [];
    lf_obj.verbosity = 1;
    lf_obj.ncores = 12;
    
    % copy parameters
    if isfield(params(i),'prepend_data'),   lf_obj.prepend_data = params(i).prepend_data;   end
    if isfield(params(i),'normalization'),  lf_obj.normalization = params(i).normalization; end
    if isfield(params(i),'envelope'),       lf_obj.envelope = params(i).envelope;           end
    if isfield(params(i),'permutations'),   lf_obj.permutations = params(i).permutations;   end
    if isfield(params(i),'npermutations'),  lf_obj.npermutations = params(i).npermutations; end
    
    if ~lf_obj.permutations
        lf_obj.npermutations = 1;
    end
    
    % set up view
    pdc_view = pdc_analysis_create_view(...
        file_sources_info,...
        'downsample',params(i).downsample);
    
    if lf_obj.envelope
        view_switch(pdc_view,'10');
        % following views at 0-5 Hz
    else
        view_switch(pdc_view,'beta');
        % following views at 15-25 Hz
    end
    
    % set up pdc analysis
    pdc_obj = PDCAnalysis(...
        lf_obj,'view',pdc_view,'outdir',p.Results.outdir);
    pdc_obj.ncores = 12;
    
    %% tune parameters
    if flag_tune
        
        if isfield(params(i),'tune_criteria_samples')
            pct = params(i).tune_criteria_samples;
        else
            pct = [0.05 0.95];
        end
        
        if length(pct) ~= 2
            error('bad length for tune_criteria_samples');
        end
        if any(pct <= 0) || any(pct >= 1)
            error('tune_criteria_samples needs to be in the interval [0 1]');
        end
        
        idx_start = floor(nsamples*pct(1));
        idx_end = ceil(nsamples*pct(2));
        pdc_obj.analysis_lf.tune_criteria_samples = [idx_start idx_end];
        
        pdc_obj.analysis_lf.tune_plot_order = true;
        
        % tune
        pdc_obj.analysis_lf.preprocessing();
        pdc_obj.analysis_lf.tune(...
            params(i).ntrials,...
            params(i).order,...
            'lambda',params(i).lambda,...
            'gamma',params(i).gamma);
    end
    
    if flag_run
        
        % set up filter
        pdc_obj.analysis_lf.set_filter(...
            nchannels,...
            params(i).order,...
            params(i).ntrials,...
            'lambda',params(i).lambda,...
            'gamma',params(i).gamma);
        
        % loop over metrics
        for j=1:length(params(i).metrics)
            
            %% pdc analysis
            
            pdc_obj.pdc_downsample = params(i).downsample;
            pdc_obj.pdc_metric = params(i).metrics{j};
            pdc_obj.pdc_nfreqs = params(i).nfreqs;
            pdc_obj.pdc_nfreqscompute = params(i).nfreqscompute;
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
            
            % loop over permutations
            for k=1:lf_obj.npermutations
                % switch loaded data
                pdc_obj.view.load('pdc','file_idx',k);
                
                %% plot seed
                if p.Results.flag_plot_seed
                    %pdc_obj.plot_seed(...
                    %    'operation','none',...
                    %    'threshold_mode','none',...
                    %    'stat','mean',...
                    %    'vertlines',[0 0.5]);
                    
                    if lf_obj.envelope
                        view_switch(pdc_view,'10');
                        % following views at 0-10 Hz
                    else
                        view_switch(pdc_view,'beta');
                        % following views at 15-25 Hz
                    end
                    
                    for idx_param=1:length(params_plot_seed)
                        params_plot = params_plot_seed{idx_param};
                        pdc_obj.plot_seed(...
                            params_plot{:},...
                            'operation','none',...
                            'vertlines',[0 0.5]);
                        %pdc_obj.plot_seed(...
                        %    params_plot{:},...
                        %    'operation','sum');
                    end
                end
                
                %% plot connectivity
                if p.Results.flag_plot_conn
                    if lf_obj.envelope
                        view_switch(pdc_view,'5');
                        % following views at 0-5 Hz
                    else
                        view_switch(pdc_view,'beta');
                        % following views at 15-25 Hz
                    end
                    nsamples_real = floor(nsamples/params(i).downsample);
                    idx_start = 0.25*nsamples_real;
                    idx_end = nsamples_real;
                    sample_idx = idx_start:idx_end;
                    
                    pdc_obj.view.plot_connectivity_matrix('samples',sample_idx);
                    
                    pdc_obj.view.save_plot('save',true,'engine','matlab');
                    close(gcf);
                end
                
            end
            
            %% plot seed variance
            if p.Results.flag_plot_seed_var
                if lf_obj.envelope
                    view_switch(pdc_view,'10');
                    % following views at 0-5 Hz
                else
                    view_switch(pdc_view,'beta');
                    % following views at 15-25 Hz
                end
                % switch loaded data
                pdc_obj.plot_seed(...
                    'operation','none',...
                    'threshold_mode','none',...
                    'stat','var',...
                    'vertlines',[0 0.5]);
            end
            
            if p.Results.flag_plot_seed_std
                if lf_obj.envelope
                    view_switch(pdc_view,'10');
                    % following views at 0-5 Hz
                else
                    view_switch(pdc_view,'beta');
                    % following views at 15-25 Hz
                end
                % switch loaded data
                pdc_obj.plot_seed(...
                    'operation','none',...
                    'threshold_mode','none',...
                    'stat','std',...
                    'vertlines',[0 0.5]);
            end
        end
        
        
    end
end

end