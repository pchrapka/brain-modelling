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
        
        analysis_lf;
        
        % data info
        % prepend? flipped data? or do i take care of that in the data
        % phase outside of this class
        
        ncores = 1;
        
        % TODO move the rest to LatticeFilterAnalysis
        % lattice filter options
        ntrials = 0;
        filter_func = 'MCMTLOCCD_TWL4';
        gamma = 0;
        lambda = 0;
        order = 0;
        filter_verbosity = 1;
        
        % pdc options
        pdc_downsample = 1;
        pdc_metric = 'euc';
        
        % tuning options
        tune_plot_gamma = false;
        tune_plot_lambda = false;
        tune_plot_order = false;
        tune_criteria_samples = [];
        
        % surrogate analysis options
        surrogate_null_mode = '';
        surrogate_nresamples = 0;
        surrogate_alpha = 0;
        
        
    end
    
    methods
        function obj = PDCAnalysis(analysis_lf,view,outdir)
            
            p = inputParser();
            addRequired(p,'analysis_lf',@(x) isa(x,'LatticeFilterAnalysis'));
            addRequired(p,'view',@(x) isa(x,'ViewPDC'));
            addRequired(p,'outdir',@ischar);
            parse(p,analysis_lf,view,outdir);
            
            % TODO what about a parameter list of inputs? or just let
            % whoever modify them as required using the properties
            % TODO sanity check data in data_file?
            %obj.file_data = data_file;
            % TODO remove dependence on file_data
            obj.analysis_lf = analysis_lf;
            obj.view = view;
            obj.outdir = outdir;
        end
        
        function pdc(obj)
            % compute pdc
            
            % preprocess data
            obj.analysis_lf.preprocessing();
            
            % set up filter
            % TODO do outside PDCAnalysis??
            filter_func_handle = str2func(obj.filter_func);
            filters{1} = filter_func_handle(obj.analysis_lf.nchannels,obj.order,obj.ntrials,...
                'lambda',obj.lambda,'gamma',obj.gamma);
            
            obj.analysis_lf.filter = filters{1};
            
            % run and postprocess
            obj.analysis_lf.run();
            obj.analysis_lf.postprocessing();
            
            % save data file
            obj.file_lf = obj.analysis_lf.file_data_post{1};
            
            if obj.ncores > 1
                % set up parfor
                parfor_setup('cores',obj.ncores,'force',true);
            end
            
            % compute pdc
            pdc_params = {...
                'metric',obj.pdc_metric,...
                'downsample',obj.pdc_downsample,...
                };
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
                'run_options',{'warmup',obj.analysis_lf.warmup},...
                'null_mode',obj.surrogate_null_mode,...
                'nresamples',obj.surrogate_nresamples,...
                'alpha',obj.surrogate_alpha,...
                'pdc_params',{'metric',obj.pdc_metric,'downsample',obj.pdc_downsample});
            
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
            
            % TODO use LatticeFilterAnalysis.tune()
            
            % copy data file for tuning, since
            % tune_lattice_filter_parameters sets up a directory based on
            % the name
            % TODO is this necessary, why not set up a tuning folder
            % inside?
            tune_file = strrep(obj.file_data,'.mat','-tuning.mat');
            if ~exist(tune_file,'file') || isfresh(tune_file,obj.file_data)
                if exist(tune_file,'file')
                    delete(tune_file);
                end
                copyfile(obj.file_data, tune_file);
            end
            
            % run the tuning function
            tune_lattice_filter_parameters(...
                tune_file,... % is this just the source file?
                obj.outdir,...
                'plot_gamma',obj.tune_plot_gamma,...
                'plot_lambda',obj.tune_plot_lambda,...
                'plot_order',obj.tune_plot_order,...
                'filter',obj.filter_func,...
                'ntrials',obj.ntrials,...
                'gamma',obj.gamma,...
                'lambda',obj.lambda,...
                'order',obj.order,...
                'run_options',{'warmup',obj.analysis_lf.warmup},...
                'criteria_samples',obj.tune_criteria_samples);
        end
        
        function plot_seed(obj,varargin)
            % pdc seed plots for all channels and both incoming and outgoing
            
            directions = {'outgoing','incoming'};
            for direc=1:length(directions)
                params_plot = [varargin, {'direction',directions{direc}}];
                for ch=1:obj.analysis_lf.nchannels

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

