function eeg_induced(sources_file, eeg_file, lf_file, varargin)
%EEG_INDUCED computes induced sources from source analysis
%   EEG_INDUCED(sources_file, eeg_file, lf_file, ...) computes induced
%   sources from source analysis
%
%   Input
%   -----
%   sources_file (string)
%       absolute file name of source analysis data
%   eeg_file (string)
%       absolute file name of final preprocessed eeg data, not timelocked
%   lf_file (string)
%       absolute file name of leadfield object from ftb.BeamformerPatch
%       object in beamformer pipeline
%
%   Parameters
%   ----------
%   outdir (string, default = pwd)
%       output directory

p = inputParser();
addRequired(p,'sources_file',@ischar);
addRequired(p,'eeg_file',@ischar);
addRequired(p,'lf_file',@ischar);
addParameter(p,'outdir','',@ischar);
parse(p,sources_file,eeg_file,lf_file,varargin{:});

if isempty(p.Results.outdir)
    outdir = pwd;
    warning('no output directory specified\nusing default %s',outdir);
else
    outdir = p.Results.outdir;
    if ~exist(outdir,'dir')
        mkdir(outdir);
    end
end

%% options

params = {...
    'recompute', false,...
    'save', true,...
    'overwrite', true,...
    'outpath', outdir,...
    };

%% load leadfield data

lf = loadfile(lf_file);

%% convert source analysis to EEG data structure

params2 = {'labels', lf.filter_label(lf.inside)};
params2 = [params2 params];
cfg = [];
cfg.eeg = eeg_file;
cfg.sources = sources_file;
file_eeg = fthelpers.run_ft_function('fthelpers.ft_sources2trials',cfg,params2{:});

%% compute phase-locked avg

file_phaselocked = fthelpers.run_ft_function('fthelpers.ft_phaselocked',[],'datain',file_eeg,params{:});

%% compute induced response

cfg = [];
cfg.trials = file_eeg;
cfg.phaselocked = file_phaselocked;
file_induced = fthelpers.run_ft_function('fthelpers.ft_induced',cfg,params{:});

end