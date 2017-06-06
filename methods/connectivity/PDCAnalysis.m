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
        
        % pdc options
        pdc_downsample = 1;
        pdc_metric = 'euc';
        
        % surrogate analysis options
        surrogate_null_mode = '';
        surrogate_nresamples = 0;
        surrogate_alpha = 0;
        
        
    end
    
    methods
        function obj = PDCAnalysis(analysis_lf,varargin)
            
            p = inputParser();
            addRequired(p,'analysis_lf',@(x) isa(x,'LatticeFilterAnalysis'));
            addParameter(p,'view',ViewPDC(),@(x) isa(x,'ViewPDC'));
            addParameter(p,'outdir','pdc-analysis',@ischar);
            parse(p,analysis_lf,varargin{:});

            obj.analysis_lf = analysis_lf;
            obj.view = p.Results.view;
            obj.outdir = p.Results.outdir;
        end
        
        function pdc(obj)
            % compute pdc
            
            % preprocess data
            obj.analysis_lf.preprocessing();
            
            % run and postprocess
            obj.analysis_lf.run();
            obj.analysis_lf.postprocessing();
            
            % save data file
            obj.file_lf = obj.analysis_lf.file_data_post;
            
            if obj.ncores > 1
                % set up parfor
                parfor_setup('cores',obj.ncores,'force',true);
            end
            
            % compute pdc
            pdc_params = {...
                'metric',obj.pdc_metric,...
                'downsample',obj.pdc_downsample,...
                };
            pdc_files = rc2pdc_dynamic_from_lf_files(obj.file_lf,'params',pdc_params);
            obj.file_pdc = pdc_files;
            
            obj.view.file_pdc = obj.file_pdc;
        end
        
        function surrogate(obj)
            % do surrogate analysis
            % NOTE requireds pdc() to be run first, or does it?, might just
            % need analysis_lf
            
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

