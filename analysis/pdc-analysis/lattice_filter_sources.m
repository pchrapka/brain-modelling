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
%
%   Output
%   ------
%   lf_files (cell array)
%       list of output files from lattice filter analysis

p = inputParser();
addRequired(p,'filter',@(x) iscell(x) || isobject(x));
addRequired(p,'source_analysis',@(x) isstruc(x) || ischar(x));
addParameter(p,'outdir','',@ischar);
parse(p,filter,source_analysis,,varargin{:});

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

name = sprintf('lf-sources-ch%d',nchannels);

%% load data

ntrials_max = 2*ntrials;
sources_mini_file = fullfile(outdir,sprintf('%s-trials%d.mat',name,ntrials_max));
if ~exist(sources_mini_file,'file')
    
    % extract sources from the pipeline
    sources_file = fullfile(outdir,[name '.mat']);
    if exist(sources_file,'file')
        sources = loadfile(sources_file);
    else
        % load data
        if ischar(source_analysis)
            data = loadfile(source_analysis);
        else
            data = source_analysis;
        end
        % extract data
        sources = bf_get_sources(data);
        clear data;
        
        % data should be [channels time trials]
        save_tag(sources,'outfile',sources_file);
    end
    
    % don't put in more data than required i.e. ntrials + ntrials_warmup
    sources = sources(:,:,1:ntrials_max);
    save_tag(sources,'outfile',sources_mini_file);
    clear sources
end

%% run lattice filters
setup_parfor();

script_name = [outdir '.m'];
[~,data_name,~] = fileparts(script_name);

lf_files = run_lattice_filter(...
    script_name,...
    sources_mini_file,...
    'name',data_name,...
    'filters', filter,...
    'warmup_noise', true,...
    'warmup_data', true,...
    'force',false,...
    'plot_pdc', false);

end