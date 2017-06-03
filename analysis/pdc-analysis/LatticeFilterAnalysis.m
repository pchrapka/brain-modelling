classdef LatticeFilterAnalysis < handle
    
    properties
        prepend_data = 'none';
        normalization = 'eachchannel';
        envelope = false;
        samples = [];
        ntrials_max = 100;
        
        filters = {};
        warmup = {'noise','flipdata'};
        verbosity = 0;
        
        tracefields = {'Kf','Kb','Rf','ferror','berrord'};
        % added Rf for info criteria
        % added ferror for bootstrap
    end
    
    properties (SetAccess = protected)
        file_data = '';
        file_lf = '';
        
        nchannels = 0;
        ntrials = 0;
        nsamples = 0;
        
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
                switch obj.prepend_data
                    case 'flipdata'
                        out{i} = strrep(obj.file_lf{i},'.mat','-removed.mat');
                    otherwise
                        out{i} = obj.file_lf{i};
                end
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
                'filters', obj.filters,...
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
            
            % preprocess data
            if ~exist(obj.file_data_pre,'file') || isfresh(obj.file_data_pre,obj.file_data)

                data = loadfile(obj.file_data);
                if isstruct(data)
                    data = data.data;
                end
                
                [obj.nchannels,obj.nsamples,obj.ntrials] = size(data);
                
                % check how many trials are available
                if obj.ntrials < p.Results.ntrials_max
                    error('only %d trial available',obj.ntrials);
                end
                
                if isempty(obj.samples)
                    sample_idx = 1:obj.nsamples;
                else
                    sample_idx = obj.samples;
                end
                
                % don't put in more data than required i.e. ntrials + ntrials_warmup
                data = data(:,sample_idx,1:obj.ntrials_max);
                
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
                    for i=1:obj.ntrials
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
                        for i=1:obj.ntrials
                            data(:,:,i) = normalize(data(:,:,i));
                        end
                    case 'eachchannel'
                        for i=1:obj.ntrials
                            data(:,:,i) = normalizev(data(:,:,i));
                        end
                    case 'none'
                end
                
                save_tag(data,'outfile',obj.file_data_pre);
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