function analysis = create_bfanalysis_subject_specific(outdir,varargin)
%CREATE_BFANALYSIS_SUBJECT_SPECIFIC creates and initializes a subject
%specific beamformer analysis object
%   CREATE_BFANALYSIS_SUBJECT_SPECIFIC(outdir,...) creates and initializes
%   a subject specific beamformer analysis object with predefined MRI,
%   Headmodel, Electrodes and Leadfield analysis steps
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
%   hm_type (integer, default = 1)
%       head model configuration
%       1 - MRIS01, HMdipoli-cm
%       2 - MRIS01, HMopenmeeg-cm
%       3 - MRI Fieldtrip standard, HM Fieldtrip standard, useful for use
%       with atlas
%   
%   Output
%   ------
%   analysis (ftb.AnalysisBeamformer)
%       analysis object that includes MRI, Headmodel, Electrodes and
%       Leadfield

p = inputParser;
addRequired(p,'outdir',@ischar);
addParameter(p,'datadir','',@ischar);
addParameter(p,'subject_file','',@ischar);
addParameter(p,'subject_name','',@ischar);
addParameter(p,'hm_type',1);
parse(p,outdir,varargin{:});

if ~isempty(p.Results.subject_file)
    subject_specific = true;
end
% remove extension from subject file
[~,subject_file,~] = fileparts(p.Results.subject_file);

% create the AnalysisBeamformer object
analysis = ftb.AnalysisBeamformer(p.Results.outdir);

%% Create and process MRI and HM

% NOTE if you're using an atlas use hm_type = 3
% other headmodels won't work with the atlas until they're in MNI
% coordinates

switch p.Results.hm_type
    case 1
        % MRI
        params_mri = 'MRIS01.mat';
        m = ftb.MRI(params_mri,'S01');
        
        % Headmodel
        params_hm = 'HMdipoli-cm.mat';
        hm = ftb.Headmodel(params_hm,'dipoli-cm');
        
        % Add steps
        analysis.add(m);
        analysis.add(hm);
        
        % % Process pipeline
        %analysis.init();
        %analysis.process();
        
    case 2
        
        % MRI
        params_mri = 'MRIS01.mat';
        m = ftb.MRI(params_mri,'S01');
        
        % Headmodel
        params_hm = 'HMopenmeeg-cm.mat';
        hm = ftb.Headmodel(params_hm,'openmeeg-cm');
        
        % Add steps
        analysis.add(m);
        analysis.add(hm);
        
        % % Process pipeline
        %analysis.init();
        %analysis.process();
        
    case 3
        % MRI
        params_mri = [];
        params_mri.mri_data = 'std';
        m = ftb.MRI(params_mri,'std');
        
        % Headmodel
        params_hm = [];
        params_hm.fake = '';
        hm = ftb.Headmodel(params_hm,'std-cm');
        
        % Add steps
        analysis.add(m);
        analysis.add(hm);
        
        % Process pipeline
        analysis.init();
        m.load_file('mri_mat', 'standard_mri.mat');
        m.load_file('mri_segmented', 'standard_seg.mat');
        m.load_file('mri_mesh', 'MRIS01.mat'); % fake this
        hm.load_file('mri_headmodel', 'standard_bem.mat');
        % process should ignore the files above
        %analysis.process();
        
        %hm.plot({'scalp','skull','brain','fiducials'});
end

%% Create and process the electrodes

% Electrodes
params_e = [];
if subject_specific
    params_e.elec_orig = fullfile(p.Results.datadir,[subject_file '.sfp']);
    name_e = p.Results.subject_name;
else
    % Not sure what cap to use easycap-M1 has right channel names but
    % too many
    error('fix me');
end

e = ftb.Electrodes(params_e,name_e);
if subject_specific
    e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
else
    error('fix me');
end
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

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

%% Leadfield

% Leadfield
params_lf = [];
params_lf.ft_prepare_leadfield.normalize = 'yes';
params_lf.ft_prepare_leadfield.tight = 'yes';
params_lf.ft_prepare_leadfield.grid.resolution = 1;
params_lf.ft_prepare_leadfield.grid.unit = 'cm';
lf = ftb.Leadfield(params_lf,'1cm-norm-tight');
analysis.add(lf);
lf.force = false;

% Process pipeline
analysis.init();
analysis.process();

end