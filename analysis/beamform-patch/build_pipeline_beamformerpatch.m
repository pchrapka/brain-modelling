function pipeline = build_pipeline_beamformerpatch(params_subject,pipedir)
%BUILD_PIPELINE_BEAMFORMERPATCH builds a pipeline for ftb.BeamformerPatch
%   BUILD_PIPELINE_BEAMFORMERPATCH(params_subject, pipedir) builds an
%   ftb.AnalysisBeamformer pipeline for ftb.BeamformerPatch
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
%           bf      containing options for ftb.BeamformerPatch
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
param_list(k).class = 'BeamformerPatch';
param_list(k).prefix = 'BFPatch';
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

% NOTE code below is (mostly) identical to the loop above
%
% %% set up MRI
% step_name = get_analysis_step_name(params_sd.mri,'MRI');
% m = ftb.MRI(params_sd.mri,step_name);
% 
% % add step
% pipeline.add(m);
% 
% %% set up HM
% 
% step_name = get_analysis_step_name(params_sd.hm,'HM');
% hm = ftb.Headmodel(params_sd.hm,step_name);
% 
% % add step
% pipeline.add(hm);
% 
% %% set up Electrodes
% 
% step_name = get_analysis_step_name(params_sd.elec,'E');
% e = ftb.Electrodes(params_sd.elec,step_name);
% 
% % add step
% pipeline.add(e);
% e.force = false;
% 
% %     % Manually rename channel
% %     % NOTE This is why the electrodes are processed ahead of time
% %     elec = loadfile(e.elec_aligned);
% %     idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
% %     if any(idx)
% %         elec.label{idx} = 'AFz';
% %         save(e.elec_aligned,'elec');
% %     end
% 
% % % Process pipeline
% % pipeline.init();
% % pipeline.process();
% 
% % e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});
% 
% %% set up Leadfield
% 
% step_name = get_analysis_step_name(params_sd.lf,'L');
% lf = ftb.Leadfield(params_sd.lf,step_name);
% 
% % add step
% pipeline.add(lf);
% 
% lf.force = false;
% 
% % Process pipeline
% % pipeline.init();
% % pipeline.process();
% 
% %% set up EEG
% 
% step_name = get_analysis_step_name(params_sd.eeg,'EEG');
% eeg = ftb.EEG(params_sd.eeg, step_name);
% 
% % add step
% pipeline.add(eeg);
% 
% %% set up Beamformer
% 
% step_name = get_analysis_step_name(params_sd.bf,'BFPatch');
% bf = ftb.BeamformerPatchTrial(params_sd.bf,step_name);
% 
% % add step
% pipeline.add(bf);

%% init pipeline
pipeline.init();

end
