function [file_sources_info,file_sources] = eeg_prep_lattice_filter(file_sourceanalysis, file_eeg, file_lf, varargin)
%EEG_PREP_LATTICE_FILTER preps data for lattice filtering
%   EEG_PREP_LATTICE_FILTER(file_sourceanalysis, file_eeg, file_lf,,...)
%   preps data for lattice filtering
%
%   Input
%   -----
%   file_sourceanalysis (string)
%       source analysis from ftb.AnalysisBeamformer pipeline
%   file_eeg (string)
%       file name with data struct that contains the sampling rate
%   file_lf (string)
%       leadfield from source analysis
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%   patch_type (string, default = 'aal'
%       patch model type
%
%   Output
%   ------
%   file_sources_info (string)
%       file name of data file containing source data and other info
%   file_sources (string)
%       file name of data file containing only source data, required for
%       run_lattice_filter

p = inputParser();
addRequired(p,'file_sourceanalysis',@ischar);
addRequired(p,'file_eeg',@ischar);
addRequired(p,'file_lf',@ischar);
addParameter(p,'outdir','',@ischar);
addParameter(p,'patch_type','aal',@ischar);
parse(p,file_sourceanalysis,file_eeg,file_lf,varargin{:});


%% set up output dir
if isempty(p.Results.outdir)
    outdir = p.Results.patch_type;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = fullfile(p.Results.outdir,p.Results.patch_type);
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

%% set up files
    
file_sources = fullfile(outdir,'sources.mat');
file_sources_info = fullfile(outdir,'sources-info.mat');

%% extract sources from data
if ~exist(file_sources,'file') || isfresh(file_sources, file_sourceanalysis)
    
    % load data
    source_analysis = loadfile(file_sourceanalysis);
    
    % extract data
    data_sources = [];
    data_sources.data = bf_get_sources(source_analysis);
    data_sources.time = source_analysis.time;
    
    % data should be [channels time trials]
    save_tag(data_sources,'outfile',file_sources);
end

%% extract source info
if ~exist(file_sources_info,'file') || isfresh(file_sources_info, file_sourceanalysis)
    if ~exist('data_sources','var')
        data_sources = loadfile(file_sources);
    end
    
    % get patch data
    lf = loadfile(file_lf);
    patch_labels = lf.filter_label(lf.inside);
    patch_labels = cellfun(@(x) strrep(x,'_',' '),...
        patch_labels,'UniformOutput',false);
    
    % get eeg data
    eeg_data = loadfile(file_eeg);
    
    data = [];
    data.nchannels = size(data_sources.data,1);
    data.nsamples = length(data_sources.time);
    data.labels = patch_labels;
    data.centroids = lf.patch_centroid(lf.inside,:);
    data.time = data_sources.time;
    data.patch_type = p.Results.patch_type;
    data.fsample = eeg_data.fsample;
    
    % save
    save_parfor(file_sources_info, data);
end

end