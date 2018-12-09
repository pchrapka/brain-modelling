function pipeline = build_pipeline_beamformer_rmv(params_subject,pipedir)
%BUILD_PIPELINE_BEAMFORMER_RMV builds a pipeline for ftb.BeamformerRMV
%   BUILD_PIPELINE_BEAMFORMER_RMV(params_subject, pipedir) builds an
%   ftb.AnalysisBeamformer pipeline for ftb.BeamformerRMV
%
%   Input
%   -----
%   params_subject (string/struct)
%       parameter file or struct for subject data and beamformer configuration
%
%       this pipeline requires the following fields:
%           mri     containing options for ftb.MRI
%           hm      containing options for ftb.Headmodel
%           elec    containing options for ftb.Electrodes
%           lf      containing options for ftb.Leadfield
%           eeg     containing options for ftb.EEG
%           bf      containing options for ftb.BeamformerRMV
%
%       see paramsbf_sd_beta() for examples
%
%   pipedir (string, default=pwd/output/ftb)
%       output directory for pipeline
%
%   Output
%   ------
%   pipeline (ftb.AnalysisBeamformer object)
%       return an ftb.AnalysisBeamformer object

p = inputParser();
addRequired(p,'params_subject',@(x) ischar(x) || isstruct(x));
addOptional(p,'pipedir','',@ischar);
parse(p,params_subject,pipedir);

%% set up output folder

if isempty(p.Results.pipedir)
    % use folder common to all experiments to avoid recomputation
    pipedir = fullfile(pwd,'output','ftb');
    fprintf('using default pipeline output directory:\n\t%s\n',pipedir);
end

% %% set up parallel pool
% parfor_setup();

%% get subject specific parameters

if ischar(params_subject)
    params_func = str2func(params_subject);
    params_sd = params_func();
else
    params_sd = params_subject;
    %params_subject = params_sd.name;
end

%% set up beamformer analysis

pipeline = ftb.AnalysisBeamformer(pipedir);


param_list = [];
k = 1;

param_list(k).field = 'mri';
param_list(k).class = 'MRI';
param_list(k).prefix = 'MRI';
k = k+1;

param_list(k).field = 'hm';
param_list(k).class = 'Headmodel';
param_list(k).prefix = 'HM';
k = k+1;

param_list(k).field = 'elec';
param_list(k).class = 'Electrodes';
param_list(k).prefix = 'E';
k = k+1;

param_list(k).field = 'lf';
param_list(k).class = 'Leadfield';
param_list(k).prefix = 'L';
k = k+1;

param_list(k).field = 'eeg';
param_list(k).class = 'EEG';
param_list(k).prefix = 'EEG';
k = k+1;

param_list(k).field = 'bf';
param_list(k).class = 'BeamformerRMV';
param_list(k).prefix = 'BFRMV';
k = k+1;

%% add analysis steps
for i=1:length(param_list)
    field = param_list(i).field;
    
    if isfield(params_sd,field)
        % generate the pipeline step name
        step_name = get_analysis_step_name(params_sd.(field),param_list(i).prefix);
        % generate the constructor function
        ftb_handle = str2func(['ftb.' param_list(i).class]);
        % call the constructor for the current step
        step = ftb_handle(params_sd.(field),step_name);
        
        % add step
        pipeline.add(step);
    else
        fprintf('missing %s params\n',field);
    end

end

%% init pipeline
pipeline.init();

end
