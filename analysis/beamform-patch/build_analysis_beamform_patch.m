function analysis = build_analysis_beamform_patch()
%BUILD_ANALYSIS_BEAMFORM_PATCH builds analysis pipeline for patch
%beamforming

do_run = false;

%% Analysis params

% subject specific info
[datadir,subject_file,subject_name] = get_coma_data(22);

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','..','experiments','output-common','fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

%% Beamform data
analysis = {};

% std
stimulus = 'std';
analysis{1} = analysis_eeg_beamform_patch(...
    out_folder,...
    'datadir', datadir,...
    'subject_file', subject_file,...
    'subject_name', subject_name,...
    'stimulus', stimulus);

if do_run
    analysis{1}.process();
end

stimulus = 'odd';
analysis{2} = analysis_eeg_beamform_patch(...
    out_folder,...
    'datadir', datadir,...
    'subject_file', subject_file,...
    'subject_name', subject_name,...
    'stimulus', stimulus);

if do_run
    analysis{2}.process();
end

end