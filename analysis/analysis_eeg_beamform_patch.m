function analysis = analysis_eeg_beamform_patch(outdir,varargin)
%ANALYSIS_EEG_BEAMFORM_PATCH apply patch beamformer to EEG data
%   ANALYSIS_EEG_BEAMFORM_PATCH applies the patch beamformer to EEG data
%
%   Input
%   -----
%   outdir (string)
%       path of output folder
%   
%   Parameters
%   ----------
%   datadir (string)
%       path of data folder
%   subject_file (string)
%       file name of subject specific data
%   subject_name (string)
%       name of subject
%   stimulus (string)
%       selects which stimulus to process: std, odd    
%   
%   Output
%   ------
%   analysis (ftb.AnalysisBeamformer)
%       analysis object that includes MRI, Headmodel, Electrodes,
%       Leadfield, EEG and BeamformerPatchTrial

p = inputParser;
addRequired(p,'outdir',@ischar);
addParameter(p,'datadir','',@ischar);
addParameter(p,'subject_file','',@ischar);
addParameter(p,'subject_name','',@ischar);
addParameter(p,'stimulus','std',@(x)any(validatestring(x,{'std','odd'})));
parse(p,outdir,varargin{:});


%% Set up beamformer analysis
hm_type = 3;
analysis = create_bfanalysis_subject_specific(p.Results.outdir,...
    'datadir', p.Results.datadir,...
    'subject_file', p.Results.subject_file,...
    'subject_name', p.Results.subject_name,...
    'hm_type',hm_type);

%% EEG

params_eeg = EEGstddev(p.Results.datadir, p.Results.subject_file, p.Results.stimulus);
eeg = ftb.EEG(params_eeg, p.Results.stimulus);
analysis.add(eeg);

%% Beamformer

params_bf = 'BFPatchAALCustom.mat';
if ~exist(params_bf,'file')
    BFPatchAALCustom();
end
bf = ftb.BeamformerPatchTrial(params_bf,'lcmvmom');
analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();

end