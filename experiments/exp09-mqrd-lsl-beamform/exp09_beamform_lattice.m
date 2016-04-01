%% exp09_beamform_lattice

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


%% Select data for lattice filter
stimulus = {'std','odd'};
data = analysis_select_data(analysis,stimulus,'trials',100);

%% Lattice filter
% set lattice filter params
order = 10;
lambda = 0.99;
verbose = 0;

lattice_folder = fullfile(srcdir,'..','lattice');
if ~exist(lattice_folder,'dir')
    mkdir(lattice_folder);
end

analysis_eeg_lattice(data,'outdir',lattice_folder,...
    'order',order,'lambda',lambda,'verbose',verbose);
