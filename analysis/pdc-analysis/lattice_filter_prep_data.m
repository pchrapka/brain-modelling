function [sources_data_file,sources_mini_file] = lattice_filter_prep_data(pipeline, varargin)
%LATTICE_FILTER_PREP_DATA preps data for lattice filtering
%   LATTICE_FILTER_PREP_DATA(pipeline,...) preps data for lattice filtering
%
%   Input
%   -----
%   pipeline
%       ftb.AnalysisBeamformer pipeline
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%
%   ntrials_max (integer, default = 40)
%       maximum number of trials to pass to filter function
%   samples (integer, default = all)
%       sample indices to be used for filtering
%   normalization (string, default = 'none')
%       normalization type, options: allchannels, eachchannel, none
%   envelope (logical, default = false)
%       uses the envelope of each channel
%   patch_type (string, default = 'aal'
%       patch model type
%
%   verbosity (integer, default = 0)
%       verbosity level
%
%   Output
%   ------
%   sources_data_file (string)
%       file name of data file containing source data and other info
%   sources_mini_file (string)
%       file name of data file containing only source data, required for
%       run_lattice_filter

p = inputParser();
addRequired(p,'pipeline',@(x) isa(x,'ftb.AnalysisBeamformer'));
addParameter(p,'outdir','',@ischar);
addParameter(p,'ntrials_max',40,@isnumeric);
addParameter(p,'samples',[],@isnumeric);
addParameter(p,'verbosity',0,@isnumeric);
options_norm = {'allchannels','eachchannel','none'};
addParameter(p,'normalization','none',@(x) any(validatestring(x,options_norm)));
addParameter(p,'envelope',false,@islogical);
addParameter(p,'patch_type','aal',@ischar);
parse(p,pipeline,varargin{:});


%% set up output dir
if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

%% get patch data
lf_file = pipeline.steps{end}.lf.leadfield;

lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);

nchannels = npatch_labels;

%% create the name

name = sprintf('lf-sources-ch%d',nchannels);

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

sources_file_tag = sprintf('%s-trials%d-%s-%s-%s',...
        name, p.Results.ntrials_max, slug_samples, slug_norm, slug_env);
sources_mini_file = fullfile(outdir, sprintf('%s-for-filter.mat',sources_file_tag));
sources_data_file = fullfile(outdir, sprintf('%s.mat',sources_file_tag));

% get source analysis from pipeline
source_analysis = pipeline.steps{end}.sourceanalysis;

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

if ~exist(sources_data_file,'file')
    
    if ischar(source_analysis)
        % load if it hasn't been loaded
        source_analysis = loadfile(source_analysis);
    end
    
    data = [];
    data.sources_file = sources_mini_file;
    data.normalization = p.Results.normalization;
    data.labels = patch_labels;
    data.centroids = lf.patch_centroid(lf.inside,:);
    data.time = sources_analysis.time{1};
    data.patch_type = p.Results.patch_type;
    data.fsample = sources_analysis.fsample;
    error('check data.time');
    
    % save
    save_parfor(sources_data_file, data);
end

end