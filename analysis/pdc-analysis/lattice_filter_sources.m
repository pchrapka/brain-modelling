function lf_files = lattice_filter_sources(filter, source_analysis, varargin)
%LATTICE_FILTER_SOURCES applies lattice filter to brain sources
%   LATTICE_FILTER_SOURCES(filter, source_analysis,...) applies lattice
%   filter to brain sources
%
%   Input
%   -----
%   filter (filter object or cell array of filter objects)
%       lattice filter object(s)
%   source_analysis (string/struct)
%       source analysis file or struct from beamformer pipeline
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%   ntrials_max (integer, default = 40)
%       maximum number of trials to pass to filter function
%   samples (integer, default = all)
%       sample indices to be used for filtering
%   tracefields (cell array, default = {'Kf','Kb'})
%       fields to save from LatticeTrace object
%   normalization (string, default = 'none')
%       normalization type, options: allchannels, eachchannel, none
%   envelope (logical, default = false)
%       uses the envelope of each channel
%   verbosity (integer, default = 0)
%       verbosity level
%
%   Output
%   ------
%   lf_files (cell array)
%       list of output files from lattice filter analysis

p = inputParser();
addRequired(p,'filter',@(x) iscell(x));
addRequired(p,'source_analysis',@(x) isstruct(x) || ischar(x));
addParameter(p,'outdir','',@ischar);
addParameter(p,'ntrials_max',40,@isnumeric);
addParameter(p,'samples',[],@isnumeric);
addParameter(p,'verbosity',0,@isnumeric);
addParameter(p,'tracefields',{'Kf','Kb'},@iscell);
options_norm = {'allchannels','eachchannel','none'};
addParameter(p,'normalization','none',@(x) any(validatestring(x,options_norm)));
addParameter(p,'envelope',false,@islogical);
parse(p,filter,source_analysis,varargin{:});

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

name = sprintf('lf-sources-ch%d',filter{1}.nchannels);

%% load data

if isempty(p.Results.samples)
    slug_samples = 'samplesall';
else
    slug_samples = sprintf('samples%d-%d',...
        min(p.Results.samples), max(p.Results.samples));
end

slug_norm = sprintf('norm%s',p.Results.normalization);
if p.Results.envelope
    slug_env = 'envyes';
else
    slug_env = 'envno';
end

sources_mini_file = fullfile(outdir,...
        sprintf('%s-trials%d-%s-%s-%s.mat',...
        name, p.Results.ntrials_max, slug_samples, slug_norm, slug_env));

if ~exist(sources_mini_file,'file')
    
    % extract sources from the pipeline
    sources_file = fullfile(outdir,[name '.mat']);
    if exist(sources_file,'file')
        sources = loadfile(sources_file);
    else
        % load data
        if ischar(source_analysis)
            source_analysis = loadfile(source_analysis);
        end
        % extract data
        sources = bf_get_sources(source_analysis);
        clear source_analysis;
        
        % data should be [channels time trials]
        save_tag(sources,'outfile',sources_file);
    end
    
    % check how many trials are available
    ntrials = size(sources,3);
    if ntrials < p.Results.ntrials_max
        error('only %d trial available',ntrials);
    end
    
    if isempty(p.Results.samples)
        sample_idx = 1:size(sources,2);
    else
        sample_idx = p.Results.samples;
    end
    
    % don't put in more data than required i.e. ntrials + ntrials_warmup
    sources = sources(:,sample_idx,1:p.Results.ntrials_max);
    
    [nchannels,~,ntrials] = size(sources);
    
    % compute envelope
    if p.Results.envelope
        for i=1:ntrials
            for j=1:nchannels
                temp = abs(hilbert(sources(j,:,i)));
                sources(j,:,i) = temp - mean(temp);
            end
        end
    end
    
    % data normalization
    switch p.Results.normalization
        case 'allchannels'
            for i=1:ntrials
                sources(:,:,i) = normalize(sources(:,:,i));
            end
        case 'eachchannel'
            for i=1:ntrials
                sources(:,:,i) = normalizev(sources(:,:,i));
            end
        case 'none'
    end
    
    save_tag(sources,'outfile',sources_mini_file);
    clear sources
end

%% run lattice filters
parfor_setup();

% filter results are dependent on all input file parameters
[~,exp_name,~] = fileparts(sources_mini_file);

lf_files = run_lattice_filter(...
    sources_mini_file,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filter,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'verbosity',p.Results.verbosity,...
    'tracefields',p.Results.tracefields,...
    'plot_pdc', false);

end