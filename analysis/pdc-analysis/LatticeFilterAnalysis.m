classdef LatticeFilterAnalysis < handle
    
    properties
        
        prepend_data = 'none';
        normalization = 'eachchannel';
        envelope = false;
        samples = [];
        ntrials_max = 100;
        
        filter;
        warmup = {'noise','flipdata'};
        verbosity = 0;
        
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
    end
    
    properties (SetAccess = protected)
        file_data = '';
        file_lf = '';
        
        outdir = '';
    end
    
    properties (Dependent)
        file_data_pre = '';
        file_data_post = '';
    end
    
    methods
        function obj = LatticeFilterAnalysis(file_data,varargin)
            p = inputParser();
            addRequired(p,'file_data',@ischar);
            addParameter(p,'outdir','lf-analysis',@ischar);
            parse(p,varargin{:});
            
            obj.file_data = file_data;
            obj.outdir = p.Results.outdir;
        end
        
        function set.normalization(obj,value)
            p = inputParser();
            options_norm = {'allchannels','eachchannel','none'};
            addRequired(p,'normalization',@(x) any(validatestring(x,options_norm)));
            parse(p,value);
            
            obj.normalization = p.Results.normalization;
        end
        
        function set.prepend_data(obj,value)
            p = inputParser();
            options_prepend = {'flipdata','none'};
            addRequired(p,'prepend_data',@(x) any(validatestring(x,options_prepend)));
            parse(p,value);
            
            obj.prepend_data = p.Results.prepend_data;
        end
        
        function set.envelope(obj,value)
            p = inputParser();
            addRequired(p,'envelope',@islogical);
            parse(p,value);
            
            obj.envelope = p.Results.envelope;
        end
        
        function set.samples(obj,value)
            p = inputParser();
            addRequired(p,'samples',@(x) isnumeric(x) && isvector(x));
            parse(p,value);
            
            obj.samples = value;
        end
        
        function out = get.file_data_pre(obj)
            
            % create the name
            name = 'lf-data';
            
            if isempty(obj.samples)
                slug_samples = 'samplesall';
            else
                slug_samples = sprintf('samples%d-%d',...
                    min(obj.samples), max(obj.samples));
            end
            
            slug_norm = sprintf('norm%s',obj.normalization);
            
            if obj.envelope
                slug_env = 'envyes';
            else
                slug_env = 'envno';
            end
            
            slug_prepend = sprintf('prepend%s',obj.prepend_data);
            
            slug_trials = sprintf('trials%d',obj.ntrials_max);
            
            data_file_tag = sprintf('%s-%s-%s-%s-%s-%s',...
                name, slug_trials, slug_samples, slug_norm, slug_env, slug_prepend);
            out = fullfile(obj.outdir, sprintf('%s-for-filter.mat',data_file_tag));
            
        end
        
        function out = get.file_data_post(obj)
            if isempty(obj.file_lf)
                error('empty file_lf');
            end
            
            % TODO update based on post options
            nfiles = length(obj.file_lf);
            out = cell(nfiles,1);
            for i=1:nfiles
                out{i} = strrep(obj.file_lf{i},'.mat','-removed.mat');
            end
        end
        
        function run(obj)
            % Parameters
            % verbosity
            % tracefields
            
            if isempty(obj.file_data_pre)
                error('preprocess data first');
            end
            
            if isequal(obj.prepend_data,'flipdata')
                if ~isempty(obj.warmup)
                    warning('warmup not necessary');
                    obj.warmup = {};
                end
            end
            
            % filter results are dependent on all input file parameters
            [~,exp_name,~] = fileparts(obj.file_data_pre);
            
            % compute RC with lattice filter
            obj.file_lf = run_lattice_filter(...
                obj.file_data_pre,...
                'basedir',obj.outdir,...
                'outdir',exp_name,...
                'filters', obj.filter,...
                'warmup',obj.warmup,...
                'force',false,...
                'verbosity',obj.verbosity,...
                'tracefields',obj.tracefields);
        end
        
        function tune(obj)
        end
        
        function preprocessing(obj,varargin)
            
            p = inputParser();
            addParameter(p,'verbosity',0,@isnumeric);
            parse(p,varargin{:});
            
            % TODO get nchannels? or some other name
            % should be nested in previous data processing step
            
            %sources_data_file = fullfile(outdir, sprintf('%s.mat',data_file_tag));
            % TODO include data as another variable in source file
            
            % get source analysis from pipeline
            % source_analysis = pipeline.steps{end}.sourceanalysis;
            % TODO remove dependence on pipeline
            
            % TODO save preprocessed data file in object
            if ~exist(obj.file_data_pre,'file') || isfresh(obj.file_data_pre,obj.file_data)
                
                % TODO move this outside of this function
                % create eeg_prep_lattice_filter
%                 % extract sources from the pipeline
%                 sources_file = fullfile(obj.outdir,[name '.mat']);
%                 if exist(sources_file,'file')
%                     data = loadfile(sources_file);
%                 else
%                     % load data
%                     if ischar(source_analysis)
%                         source_analysis = loadfile(source_analysis);
%                     end
%                     % extract data
%                     data = bf_get_sources(source_analysis);
%                     clear source_analysis;
%                     
%                     % data should be [channels time trials]
%                     save_tag(data,'outfile',sources_file);
%                 end

                data = loadfile(obj.file_data);
                
                [nchannels,nsamples,ntrials] = size(data);
                
                % check how many trials are available
                if ntrials < p.Results.ntrials_max
                    error('only %d trial available',ntrials);
                end
                
                if isempty(p.Results.samples)
                    sample_idx = 1:size(data,2);
                else
                    sample_idx = p.Results.samples;
                end
                
                % don't put in more data than required i.e. ntrials + ntrials_warmup
                data = data(:,sample_idx,1:p.Results.ntrials_max);
                
                switch obj.prepend_data
                    case 'flipdata'
                        data = cat(2,flipdim(data,2),data);
                    case 'none'
                        % do nothing
                    otherwise
                        error('unknown prepend mode');
                end
                
                % compute envelope
                if obj.envelope
                    for i=1:ntrials
                        for j=1:nchannels
                            temp = abs(hilbert(data(j,:,i)));
                            data(j,:,i) = temp - mean(temp);
                        end
                    end
                end
                
                % data normalization
                switch obj.normalization
                    case 'allchannels'
                        warning('this can result in bad boostrapping results');
                        for i=1:ntrials
                            data(:,:,i) = normalize(data(:,:,i));
                        end
                    case 'eachchannel'
                        for i=1:ntrials
                            data(:,:,i) = normalizev(data(:,:,i));
                        end
                    case 'none'
                end
                
                save_tag(data,'outfile',obj.file_data_pre);
            end
        end
        
        function postprocessing(obj)
        end
    end
end