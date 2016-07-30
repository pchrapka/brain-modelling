function pipeline = build_pipeline_beamformer(params_subject)
%BUILD_PIPELINE_BEAMFORMER builds beamformer pipeline
%
%   params_subject (string)
%       parameter file for subject data and beamformer configuration

%% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% use folder common to all experiments to avoid recomputation
outdir = fullfile(srcdir,'..','..','experiments','output-common','fb');

% %% set up parallel pool
% setup_parfor();

%% get subject specific parameters

params_func = str2func(params_subject);
params_sd = params_func();

%% set up beamformer analysis

pipedir = fullfile(outdir,params_subject);
pipeline = ftb.AnalysisBeamformer(pipedir);

%% set up MRI
step_name = get_analysis_step_name(params_sd.mri,'MRI');
m = ftb.MRI(params_sd.mri,step_name);

% add step
pipeline.add(m);

%% set up HM

step_name = get_analysis_step_name(params_sd.hm,'HM');
hm = ftb.Headmodel(params_sd.hm,step_name);

% add step
pipeline.add(hm);

%% Create and process the electrodes

step_name = get_analysis_step_name(params_sd.elec,'E');
e = ftb.Electrodes(params_sd.elec,step_name);

error('check fiducials');
if subject_specific
    e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
else
    error('fix me');
end
pipeline.add(e);
e.force = false;

% Process pipeline
pipeline.init();
pipeline.process();
e.force = false;

error('check elec labels');
if subject_specific
    % Manually rename channel
    % NOTE This is why the electrodes are processed ahead of time
    elec = loadfile(e.elec_aligned);
    idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
    if any(idx)
        elec.label{idx} = 'AFz';
        save(e.elec_aligned,'elec');
    end
end

% e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});

%% set up Leadfield

step_name = get_analysis_step_name(params_sd.lf,'L');
lf = ftb.Leadfield(params_sd.lf,step_name);

% add step
pipeline.add(lf);

lf.force = false;

% Process pipeline
pipeline.init();
pipeline.process();

%% set up EEG

% TODO which to use?
params_eeg = EEGstddevconsec(p.Results.datadir, p.Results.subject_file, p.Results.stimulus);
eeg = ftb.EEG(params_eeg, [p.Results.stimulus 'consec']);
pipeline.add(eeg);

%% set up Beamformer

step_name = get_analysis_step_name(params_sd.bf,'BFPatch');
bf = ftb.BeamformerPatchTrial(params_sd.bf,step_name);

% add step
pipeline.add(bf);

%% init pipeline
pipeline.init();

end