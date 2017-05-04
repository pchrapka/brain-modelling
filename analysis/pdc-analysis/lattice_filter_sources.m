function lf_files = lattice_filter_sources(sources_mini_file, varargin)
%LATTICE_FILTER_SOURCES applies lattice filter to brain sources
%   LATTICE_FILTER_SOURCES(filter, source_analysis,...) applies lattice
%   filter to brain sources
%
%   Input
%   -----
%   sources_mini_file (string)
%       file name of data file containing only source data, see
%       lattice_filter_prep_data
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory
%
%   ntrials (default = 100
%       number of trials
%   order (default = 6)
%       filter order
%   lambda (default = 0.99)
%       forgetting factor
%   gamma (default = 1);
%       regularization parameter
%
%   tracefields (cell array, default = {'Kf','Kb'})
%       fields to save from LatticeTrace object
%
%   run_options (cell array)
%       name-value options for run_lattice_filter, namely warmup options at
%       the moment
%
%   verbosity (integer, default = 0)
%       verbosity level
%
%   Output
%   ------
%   lf_files (cell array)
%       list of output files from lattice filter analysis

p = inputParser();
addRequired(p,'sources_mini_file',@ischar);
addParameter(p,'outdir','',@ischar);
addParameter(p,'verbosity',0,@isnumeric);

addParameter(p,'ntrials',10,@isnumeric);
addParameter(p,'order',6,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'gamma',1,@isnumeric);
addParameter(p,'tracefields',{'Kf','Kb'},@iscell);
addParameter(p,'run_options',{},@iscell);
parse(p,sources_mini_file,varargin{:});

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

%% set lattice options

% get nchannels from sources data
sources = loadfile(sources_mini_file);
nchannels = size(sources,1);

filters{1} = MCMTLOCCD_TWL4(nchannels,p.Results.order,p.Results.ntrials,...
    'lambda',p.Results.lambda,'gamma',p.Results.gamma);

%% run lattice filters
% set up parfor
parfor_setup('cores',12,'force',true);

% filter results are dependent on all input file parameters
[~,exp_name,~] = fileparts(sources_mini_file);

lf_files = run_lattice_filter(...
    sources_mini_file,...
    'basedir',outdir,...
    'outdir',exp_name,... 
    'filters', filters,...
    p.Results.run_options{:},...
    'force',false,...
    'verbosity',p.Results.verbosity,...
    'tracefields',p.Results.tracefields);

end