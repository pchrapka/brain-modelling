classdef LatticeFilterAnalysis < handle
    
    properties
        % preprocessing options
        prepend_data = 'none';
        normalization = 'eachchannel';
        envelope = false;
        samples = [];
        ntrials_max = [];
        
        ncores = 1;
        
        filter = [];
        
        % lattice filter options
        filter_func = '';
        warmup = {'noise','flipdata'};
        verbosity = 0;
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
        % added Rf for info criteria
        % added ferror for bootstrap
        permutations = false;
        npermutations = 1;
        
        % tuning options
        tune_plot_gamma = false;
        tune_plot_lambda = false;
        tune_plot_order = false;
        tune_criteria_samples = [];
    end
    
    properties (SetAccess = protected)
        file_data = '';
        file_lf = '';
        
        nchannels = 0;
        ntrials = 0;
        nsamples = 0;
        
        outdir = '';
        
        preprocessed = false;
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
            parse(p,file_data,varargin{:});
            
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
            
            % create post file name based on options
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
            
            if isempty(obj.ntrials_max)
                slug_trials = 'trialsall';
            else
                slug_trials = sprintf('trials%d',obj.ntrials_max);
            end
            
            data_file_tag = sprintf('%s-%s-%s-%s-%s-%s',...
                name, slug_trials, slug_samples, slug_norm, slug_env, slug_prepend);
            out = fullfile(obj.outdir, sprintf('%s.mat',data_file_tag));
            
        end
        
        function out = get.file_data_post(obj)
            if isempty(obj.file_lf)
                out = '';
                return
            end
            
            % create post file name based on options
            nfiles = length(obj.file_lf);
            out = cell(nfiles,1);
            for i=1:nfiles
                switch obj.prepend_data
                    case 'flipdata'
                        out{i} = strrep(obj.file_lf{i},'.mat','-removed.mat');
                    otherwise
                        out{i} = obj.file_lf{i};
                end
            end
        end
        
        function set_filter(obj,nchannels,order,ntrials,varargin)
            
            p = inputParser();
            addRequired(p,'nchannels',@(x) isnumeric(x) && isvector(x));
            addRequired(p,'order',@(x) isnumeric(x) && isvector(x));
            addRequired(p,'ntrials',@(x) isnumeric(x) && isvector(x));
            addParameter(p,'lambda',[],@(x) isnumeric(x) && isvector(x));
            addParameter(p,'gamma',[], @(x) isnumeric(x) && isvector(x));
            parse(p,nchannels,order,ntrials,varargin{:});
            
            filter_func_handle = str2func(obj.filter_func);
            switch obj.filter_func
                case 'MCMTLOCCD_TWL4'
                    obj.filter = filter_func_handle(nchannels,order,ntrials,...
                        'lambda',p.Results.lambda,'gamma',p.Results.gamma);
                otherwise
                    error('unknown filter func format %s',obj.filter_func);
            end
            
        end
        
        function run(obj)
            % run lattice filter
            
            % checks
            if ~obj.preprocessed
                error('preprocess data first');
            end
            
            if isempty(obj.filter)
                error('no filter specified');
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
                'ncores',obj.ncores,...
                'basedir',obj.outdir,...
                'outdir',exp_name,...
                'filters', {obj.filter},...
                'warmup',obj.warmup,...
                'permutations',obj.permutations,...
                'npermutations',obj.npermutations,...
                'force',false,...
                'verbosity',obj.verbosity,...
                'tracefields',obj.tracefields);
            
            
        end
        
         function tune(obj,ntrials,order,lambda,varargin)
            % tune lattice filter
            
            p = inputParser();
            addRequired(p,'ntrials',@(x) isnumeric(x) && isvector(x));
            addRequired(p,'order',@(x) isnumeric(x) && isvector(x));
            addParameter(p,'lambda',[],@(x) isnumeric(x) && isvector(x));
            addParameter(p,'gamma',[], @(x) isnumeric(x) && isvector(x));
            parse(p,ntrials,order,lambda,varargin{:});
            
            if ~obj.preprocessed
                error('preprocess data first');
            end
            
            % copy data file for tuning, since
            % tune_lattice_filter_parameters sets up a directory based on
            % the name
            % TODO is this necessary, why not set up a tuning folder
            % inside?
%             error('fix this');
%             tune_file = strrep(obj.file_data,'.mat','-tuning.mat');
%             if ~exist(tune_file,'file') || isfresh(tune_file,obj.file_data)
%                 if exist(tune_file,'file')
%                     delete(tune_file);
%                 end
%                 copyfile(obj.file_data, tune_file);
%             end
            
            % adjust criteria_samples
            if isempty(obj.tune_criteria_samples)
                obj.tune_criteria_samples = [1 obj.nsamples];
            end
            
            switch obj.prepend_data
                case 'flipdata'
                    % shift by nsamples
                    criteria_samples = obj.tune_criteria_samples + obj.nsamples;
                otherwise
                    criteria_samples = obj.tune_criteria_samples;
            end
            
            % run the tuning function
            %tune_file,... % is this just the source file?
            tune_lattice_filter_parameters(...
                obj.file_data_pre,...
                obj.outdir,...
                'plot_gamma',obj.tune_plot_gamma,...
                'plot_lambda',obj.tune_plot_lambda,...
                'plot_order',obj.tune_plot_order,...
                'filter',obj.filter_func,...
                'ntrials',p.Results.ntrials,...
                'gamma',p.Results.gamma,...
                'lambda',p.Results.lambda,...
                'order',p.Results.order,...
                'run_options',{'warmup',obj.warmup},...
                'criteria_samples',criteria_samples);
        end
        
        function preprocessing(obj,varargin)
            
            p = inputParser();
            addParameter(p,'verbosity',0,@isnumeric);
            parse(p,varargin{:});
            
            % preprocess data
            if ~exist(obj.file_data_pre,'file') || isfresh(obj.file_data_pre,obj.file_data)
                % NOTE do not change parameters here used to create
                % file_data_pre file name

                data = loadfile(obj.file_data);
                if isstruct(data)
                    data = data.data;
                end
                
                [obj.nchannels,obj.nsamples,obj.ntrials] = size(data);
                
                if isempty(obj.ntrials_max)
                    ntrials_pre = obj.ntrials;
                else
                    ntrials_pre = obj.ntrials_max;
                end
                
                % check how many trials are available
                if obj.ntrials < ntrials_pre
                    error('only %d trial available',obj.ntrials);
                end
                
                if isempty(obj.samples)
                    sample_idx = 1:obj.nsamples;
                else
                    sample_idx = obj.samples;
                end
                
                % don't put in more data than required i.e. ntrials + ntrials_warmup
                data = data(:,sample_idx,1:ntrials_pre);
                
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
                    for i=1:ntrials_pre
                        for j=1:obj.nchannels
                            temp = abs(hilbert(data(j,:,i)));
                            data(j,:,i) = temp - mean(temp);
                        end
                    end
                end
                
                % data normalization
                switch obj.normalization
                    case 'allchannels'
                        warning('this can result in bad boostrapping results');
                        for i=1:ntrials_pre
                            data(:,:,i) = normalize(data(:,:,i));
                        end
                    case 'eachchannel'
                        for i=1:ntrials_pre
                            data(:,:,i) = normalizev(data(:,:,i));
                        end
                    case 'none'
                end
                
                save_tag(data,'outfile',obj.file_data_pre,'overwrite',true);
                obj.preprocessed = true;
            
            else
                data = loadfile(obj.file_data_pre);
                
                [obj.nchannels,obj.nsamples,obj.ntrials] = size(data);
                
                switch obj.prepend_data
                    case 'flipdata'
                        obj.nsamples = obj.nsamples/2;
                    otherwise
                        % do nothing
                end
                obj.preprocessed = true;
            end
        end
        
        function postprocessing(obj)
            % postprocessing
            %
            %   if prepend_data = 'flipdata'
            %       removes estimates for prepended data
            
            if isempty(obj.file_lf)
                error('file_lf is empty, execute run() first');
            end
            
            switch obj.prepend_data
                case 'flipdata'
                    rm_samples = [1 obj.nsamples];
                    if ~isempty(obj.samples)
                        error('does not account for subset of samples');
                    end
                otherwise
                    fprintf('no postprocessing required\n');
                    return;
            end
            
            nfiles = length(obj.file_lf);
            out = cell(nfiles,1);
            for i=1:nfiles
                out{i} = obj.file_data_post{i};
                if ~exist(out{i},'file') || isfresh(out{i},obj.file_lf{i})
                    data = loadfile(obj.file_lf{i});
                    
                    fields = fieldnames(data.estimate);
                    nfields = length(fields);
                    for j=1:nfields
                        field = fields{j};
                        dims = size(data.estimate.(field));
                        ndims = length(dims);
                        switch ndims
                            case 2
                                data.estimate.(field)(rm_samples(1):rm_samples(2),:) = [];
                            case 3
                                data.estimate.(field)(rm_samples(1):rm_samples(2),:,:) = [];
                            case 4
                                data.estimate.(field)(rm_samples(1):rm_samples(2),:,:,:) = [];
                            otherwise
                                error('unknown dims %d',ndims);
                        end
                    end
                    
                    % save in a new file
                    save_parfor(out{i},data);
                end
            end
        end
    end
end