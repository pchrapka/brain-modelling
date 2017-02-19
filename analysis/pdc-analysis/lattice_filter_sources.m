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

sources_mini_file = fullfile(outdir,...
        sprintf('%s-trials%d-%s.mat',...
        name, p.Results.ntrials_max, slug_samples));

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
    save_tag(sources,'outfile',sources_mini_file);
    clear sources
end

%% run lattice filters
parfor_setup();

script_name = [fullfile(outdir,slug_samples) '.m'];

lf_files = run_lattice_filter(...
    script_name,...
    sources_mini_file,...
    'name',slug_samples,...
    'filters', filter,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'verbosity',p.Results.verbosity,...
    'tracefields',p.Results.tracefields,...
    'plot_pdc', false);

end