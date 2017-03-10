function params = paramsbf_sd_andrew(subject_num,deviant_percent,stimulus,varargin)
% params for subject from Andrew's beta study

p = inputParser();
addParameter(p,'patches','aal',@ischar);
parse(p,varargin{:});

[data_file,data_name,elec_file] = get_data_andrew(subject_num,deviant_percent);

%% create data specific configs
MRIicbm152();
HMicbm152_dipoli_cm();
% BFPatchAAL();
params_elec = Eandrew_warpgr_cm(elec_file, data_name);

% params_eeg = EEGandrew_stddev(data_file, data_name, stimulus);
params_eeg = EEGandrew_stddev_precomputed(data_file, data_name, stimulus);

switch p.Results.patches
    case 'aal'
        params_bf = BFPatchAAL_andrew(data_name);
    case 'aal-coarse-13'
        params_bf = BFPatchAAL13_andrew(data_name);
    case 'aal-coarse-19'
        params_bf = BFPatchAAL19_andrew(data_name);
    case 'aal-coarse-19-plus2'
        params_bf = BFPatchAAL19_andrew(data_name,...
            'flag_add_auditory',true);
    case 'aal-coarse-19-outer-plus2'
        params_bf = BFPatchAAL19_andrew(data_name,...
            'flag_add_auditory',true,...
            'flag_outer',true);
    case 'aal-coarse-19-outer-nocer-plus2'
        params_bf = BFPatchAAL19_andrew(data_name,...
            'flag_add_auditory',true,...
            'flag_outer',true,...
            'flag_nocerebellum',true);
    otherwise
        error('add new BeamformerPatch config for %s',p.Results.patches);
end

%% assign configs for analysis
params = [];
params.mri = 'MRIicbm152.mat';
params.hm = 'HMicbm152-dipoli-cm.mat';
params.elec = params_elec;
params.lf = 'L1cm-norm-tight.mat';
params.eeg = params_eeg;
params.bf = params_bf;

end