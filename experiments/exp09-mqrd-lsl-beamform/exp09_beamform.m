%% exp09_beamform

%% Analysis params

% subject specific info
datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject_file = 'BC.HC.YOUTH.P020-10834';
% subject_file = 'BC.HC.YOUTH.P021-10852';
subject_file = 'BC.HC.YOUTH.P022-9913';
% subject_file = 'BC.HC.YOUTH.P023-10279';
subject_name = strrep(subject_file,'BC.HC.YOUTH.','');

% set up output folder
% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-fb');
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

stimulus = 'odd';
analysis{2} = analysis_eeg_beamform_patch(...
    out_folder,...
    'datadir', datadir,...
    'subject_file', subject_file,...
    'subject_name', subject_name,...
    'stimulus', stimulus);

%% Lattice filter