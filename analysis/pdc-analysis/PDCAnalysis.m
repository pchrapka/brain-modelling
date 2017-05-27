classdef PDCAnalysis < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        file_data = '';
        file_pdc = '';
        file_pdc_sig = '';
        files_pdc_resample = {};
        file_lf = '';
        
        outdir;
        
        view;
        % what do i do with plots?
        % configure a few to make it easier?
        
        % data info
        % prepend? flipped data? or do i take care of that in the data
        % phase outside of this class
        
        % lattice filter options
        ntrials = 0;
        nchannels = 0;
        filter_name = 'MCMTLOCCD_TWL4';
        gamma = 0;
        lambda = 0;
        order = 0;
        warmup = {'noise','flipdata'};
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
        % added Rf for info criteria
        % added ferror for bootstrap
        
        filter_post_remove_samples = [];
        
        % pdc options
        downsample = 1;
        metric = 'euc';
        
        % tuning options
        tune_plot_gamma = false;
        tune_plot_lambda = false;
        tune_plot_order = false;
        tune_criteria_samples = [];
        
        % surrogate analysis options
        surrogate_null_mode = '';
        surrogate_nresamples = 0;
        surrogate_alpha = 0;
        
        % surrogate plot options
        %surrogate_threshold_mode = 'significance';
        
    end
    
    methods
        function obj = PDCAnalysis(data_file,view,outdir)
            
            p = inputParser();
            addRequired(p,'data_file',@ischar);
            addRequired(p,'view',@(x) isa(x,'ViewPDC'));
            addRequired(p,'outdir',@ischar);
            parse(p,data_file,view,outdir);
            
            % TODO what about a parameter list of inputs? or just let
            % whoever modify them as required using the properties
            % TODO sanity check data in data_file
            obj.file_data = data_file;
            obj.view = view;
            obj.outdir = outdir;
        end
        
        function pdc(obj)
            % compute pdc
            
            % compute RC with lattice filter
            % TODO replace lattice_filter_sources with content from that
            % function
            lf_files = lattice_filter_sources(...
                obj.file_data,...
                'outdir',obj.outdir,... 
                'run_options',{'warmup',obj.warmup},...
                'tracefields', obj.tracefields,...
                'verbosity',0,...
                'ntrials',obj.ntrials,...
                'gamma',obj.gamma,...
                'lambda',obj.lambda,...
                'order',obj.order);
            
            if ~isempty(obj.filter_post_remove_samples)
                lf_files = lattice_filter_remove_data(lf_files,obj.filter_post_remove_samples);
            end
            obj.file_lf = lf_files{1};
            
            % compute pdc
            pdc_params = {...
                'metric',obj.metric,...
                'downsample',obj.downsample,...
                };
            % TODO replace rc2pdc_dynamic_from_lf_files, i'm only doing one
            % file
            pdc_files = rc2pdc_dynamic_from_lf_files(lf_files,'params',pdc_params);
            obj.file_pdc = pdc_files{1};
            
            obj.view.file_pdc = obj.file_pdc;
        end
        
        function surrogate(obj)
            % do surrogate analysis
            % NOTE requireds pdc() to be run first
            
            % NOTE need prepend, normalization
            % NOTE sources_file if estimate_ind_channels
            [obj.file_pdc_sig, obj.files_pdc_resample] = pdc_bootstrap(...
                obj.file_lf,...
                sources_data_file,... % TODO how do i get this info?
                'run_options',{'warmup',obj.warmup},...
                'null_mode',obj.surrogate_null_mode,...
                'nresamples',obj.surrogate_nresamples,...
                'alpha',obj.surrogate_alpha,...
                'pdc_params',{'metric',obj.metric,'downsample',obj.downsample});
            
            % add significance threshold data
            obj.view.file_pdc_sig = obj.file_pdc_sig;
            
        end
        
        function plot_significance_level(obj)
            % plot significance level
            
            obj.view.file_pdc = obj.file_pdc_sig;
            params = {
                'threshold_mode','numeric',...
                'threshold',0.001,...
                'vertlines',[0 0.5],...
                };
            obj.plot_seed(params{:});
            
            % switch back to original
            obj.view.file_pdc = obj.file_pdc;
        end
        
        function plot_surrogate_pdc(obj,varargin)
            p = inputParser();
            addParameter(p,'nplots',5,@(x) isnumeric(x) && (x <= obj.surrogate_nresamples));
            parse(p,varargin{:});
            
            % plot pdc for each surrogate data set
            for k=1:p.Results.nplots
                
                obj.view.file_pdc = obj.files_pdc_resample{k};
                
                params = {
                    'threshold_mode','numeric',...
                    'threshold',0.001,...
                    'vertlines',[0 0.5],...
                    };
                obj.plot_seed(params{:})
            end
            
            % switch back to original
            obj.view.file_pdc = obj.file_pdc;
        end
        
        function tune(obj)
            % tune lattice filter
            
            tune_lattice_filter_parameters(...
                tune_file,... % is this just the source file?
                obj.outdir,... % TODO
                'plot_gamma',obj.tune_plot_gamma,...
                'plot_lambda',obj.tune_plot_lambda,...
                'plot_order',obj.tune_plot_order,...
                'filter',obj.filter_name,...
                'ntrials',obj.ntrials,...
                'gamma',obj.gamma,...
                'lambda',obj.lambda,...
                'order',obj.order,...
                'run_options',{'warmup',obj.warmup},...
                'criteria_samples',obj.tune_criteria_samples);
        end
        
        function plot_seed(obj,varargin)
            % pdc seed plots for all channels and both incoming and outgoing
            
            nchannels = length(obj.view.info.label);
            
            directions = {'outgoing','incoming'};
            for direc=1:length(directions)
                params_plot = [varargin, {'direction',directions{direc}}];
                for ch=1:nchannels

                    % get the save tag only
                    obj.view.plot_seed(ch, params_plot{:},...
                        'get_save_tag',true);
                    [outdir_seed, outfile] = obj.view.get_fullsavefile();
                    
                    file_name_date = datestr(now, 'yyyy-mm-dd');
                    if exist(fullfile([outdir_seed '/img'],[file_name_date '-' outfile '.eps']),'file')
                        fprintf('%s: skipping %s\n',mfilename,outfile);
                        continue;
                    end
                    
                    % plot for reals
                    created = obj.view.plot_seed(ch, params_plot{:});
                    
                    if created
                        obj.view.save_plot('save',true,'engine','matlab');
                    end
                    close(gcf);
                end
            end
            
        end
    end
    
end

