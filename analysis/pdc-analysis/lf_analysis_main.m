function [lf_files,sources_mini_file] = lf_analysis_main(pipeline,outdir,varargin)

p = inputParser();
% addRequired(p,'pipeline',@(x) isa(x,'ftb.AnalysisBeamformer'));
addRequired(p,'outdir',@ischar);
addParameter(p,'ntrials',10,@isnumeric);
addParameter(p,'order',6,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'gamma',1,@isnumeric);
addParameter(p,'normalization','allchannels',@ischar); % also none
addParameter(p,'envelope',false,@islogical); % also none
addParameter(p,'tracefields',{'Kf','Kb','Rf'},@iscell);
parse(p,pipeline,outdir,varargin{:});

lf_file = pipeline.steps{end}.lf.leadfield;
sources_file = pipeline.steps{end}.sourceanalysis;

%% set lattice options

lf = loadfile(lf_file);
patch_labels = lf.filter_label(lf.inside);
patch_labels = cellfun(@(x) strrep(x,'_',' '),...
    patch_labels,'UniformOutput',false);
npatch_labels = length(patch_labels);
clear lf;

nchannels = npatch_labels;

filters{1} = MCMTLOCCD_TWL4(nchannels,p.Results.order,p.Results.ntrials,...
    'lambda',p.Results.lambda,'gamma',p.Results.gamma);

%% lattice filter

% set up parfor
parfor_setup('cores',12,'force',true);

verbosity = 0;
[lf_files, sources_mini_file] = lattice_filter_sources(filters, sources_file,...
    'tracefields',p.Results.tracefields,...
    'normalization',p.Results.normalization,...
    'envelope',p.Results.envelope,...
    'verbosity',verbosity,...
    ...'samples',[1:100],...
    'ntrials_max',100,...
    'outdir', outdir);

end