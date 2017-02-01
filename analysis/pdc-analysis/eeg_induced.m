function eeg_induced(subject, deviant_percent, stimulus, varargin)

p = inputParser();
addRequired(p,'subjecct',@isnumeric);
addRequired(p,'deviant_percent',@(x) isequal(x,10) || isequal(x,20));
addRequired(p,'stimulus',@(x) any(validatestring(x,{'std','odd'})));
addParameter(p,'patches','aal',@(x) any(validatestring(x,{'aal','aal-coarse-13'})));
parse(p,varargin{:});

script_name = mfilename('fullpath');
[script_dir,~,~] = fileparts([script_name '.m']);

%%
[~,data_name,~] = get_data_andrew(subject,deviant_percent);

data_name2 = sprintf('%s-%s',stimulus,data_name);
outdir = fullfile(script_dir,'output',data_name2);

params = {...
    'recompute', false,...
    'save', true,...
    'overwrite', true,...
    'outpath', outdir,...
    };

%% beamforming

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(...
    subject,deviant_percent,stimulus,'patches',patches_type)); 
pipeline.process();

%%

eeg_file = fullfile('output',data_name2,'ft_rejectartifact.mat');
lf = loadfile(pipeline.steps{end}.lf.leadfield);

%% convert source analysis to EEG data structure

sources_file = pipeline.steps{end}.sourceanalysis;
params2 = {sources_file, eeg_file, 'labels', lf.filter_label(lf.inside)};
params2 = [params2 params];
file_eeg = fthelpers.run_ft_function('fthelpers.ft_sources2trials',[],params2{:});

%% compute phase-locked avg

file_phaselocked = fthelpers.run_ft_function('fthelpers.ft_phaselocked',[],'datain',file_eeg,params{:});

%% compute induced response

params2 = {file_phaselocked};
params2 = [params2 params];
file_induced = fthelpers.run_ft_function('fthelpers.ft_induced',[],'datain',file_eeg,params2{:});

end