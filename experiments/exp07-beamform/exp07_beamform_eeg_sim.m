%% exp07_beamform_eeg_sim
% Goal: 
%   Apply beamforming to simulated EEG data

close all;

doplot = true;

datadir = '/home/phil/projects/data-coma-richard/BC-HC-YOUTH/Cleaned';
% subject = 'BC.HC.YOUTH.P020-10834';
% subject = 'BC.HC.YOUTH.P021-10852';
% subject = 'BC.HC.YOUTH.P022-9913';
subject = 'BC.HC.YOUTH.P023-10279';
subject_name = strrep(subject,'BC.HC.YOUTH.','');

subject_specific = true; % select electrode configuration

% use absolute directories
[srcdir,~,~] = fileparts(mfilename('fullpath'));

%% Set up beamformer analysis
% use folder common to all experiments to avoid recomputation
out_folder = fullfile(srcdir,'..','output-common','fb');
if ~exist(out_folder,'dir')
    mkdir(out_folder);
end

analysis = ftb.AnalysisBeamformer(out_folder);

%% Create and process MRI and HM

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = 'HMdipoli-cm.mat';
hm = ftb.Headmodel(params_hm,'dipoli-cm');

% Add steps
analysis.add(m);
analysis.add(hm);

% Process pipeline
analysis.init();
analysis.process();

%% Create and process the electrodes

% Electrodes
params_e = [];
if subject_specific
    params_e.elec_orig = fullfile(datadir,[subject '.sfp']);
    name_e = subject_name;
else
    % Not sure what cap to use easycap-M1 has right channel names but
    % too many
    
    % This works
    params_e = 'E32.mat';
    name_e = '32';
    
    % Headshape method doesn't work at all
%     params_e.elec_orig = 'GSN-HydroCel-32.sfp';
%     params_e.units = 'cm'; % use cm for output
%     params_e.ft_electroderealign.method = 'headshape';
%     headshape = hm.get_mesh('scalp','mm'); % use mm for fitting
%     params_e.ft_electroderealign.headshape = headshape;
%     name_e = '32-hs';
    
%     params_e.elec_orig = 'easycap-M1.txt';
%     params_e.units = 'cm'; % use cm for output
%     params_e.ft_electroderealign.method = 'headshape';
%     headshape = hm.get_mesh('scalp','mm'); % use mm for fitting
%     params_e.ft_electroderealign.headshape = headshape;
%     name_e = 'ECapM1-hs';

%     % Only way is to do interactive which is pretty difficult without
%     % fiducials
%     params_e.elec_orig = 'easycap-M1.txt';
%     params_e.units = 'cm';
%     params_e.ft_electroderealign.method = 'interactive';
%     headshape = hm.get_mesh('scalp','mm'); % use mm for fitting
%     params_e.ft_electroderealign.headshape = headshape;
%     name_e = 'ECapM1';
end

e = ftb.Electrodes(params_e,name_e);
if subject_specific
    e.set_fiducial_channels('NAS','NZ','LPA','LPA','RPA','RPA');
else
    switch name_e
        case '32'
            e.set_fiducial_channels('NAS','FidNz','LPA','FidT9','RPA','FidT10');
            %case 'ECapM1'
            %Doesn't work, need all fiducials
            %e.set_fiducial_channels('NAS','','LPA','TP9','RPA','TP10');
    end
end
analysis.add(e);
e.force = false;

% Process pipeline
analysis.init();
analysis.process();
e.force = false;

if subject_specific
    % Manually rename channel
    elec = ftb.util.loadvar(e.elec_aligned);
    idx = cellfun(@(x) isequal(x,'Afz'),elec.label);
    if any(idx)
        elec.label{idx} = 'AFz';
        save(e.elec_aligned,'elec');
    end
end

e.plot({'scalp','fiducials','electrodes-aligned','electrodes-labels'});


%% Create the rest of the pipeline

% Create custom configs
% DSarind_cm();
BFlcmv_exp07();

% Leadfield
params_lf = 'L1cm-norm.mat';
lf = ftb.Leadfield(params_lf,'1cm-norm');
analysis.add(lf);
lf.force = false;

% EEG - simulated
params_dsim = 'DSdip3-sine-cm.mat';
dsim = ftb.DipoleSim(params_dsim,'dip3-sine-cm');
% params_dsim = 'DSsine-cm.mat';
% dsim = ftb.DipoleSim(params_dsim,'sine-cm');
analysis.add(dsim);
dsim.force = true;

% Beamformer
params_bf = 'BFlcmv-exp07.mat';
bf = ftb.Beamformer(params_bf,'lcmv-exp07');
analysis.add(bf);

%% Process pipeline
analysis.init();
analysis.process();

% FIXME NOT WORKING!!!

%% Plot all results
% TODO Check individual trials

if exist('dsim','var')
    figure;
    bf.plot({'brain','skull','scalp','fiducials','dipole'});
end

% figure;
% cfg = [];
% cfg.datafile = fullfile(datadir,datafile);
% cfg.continuous = 'yes';
% ft_databrowser(cfg);

% figure;
% cfg = ftb.util.loadvar(eeg.definetrial);
% ft_databrowser(cfg);

% figure;
% eeg.plot_data('preprocessed');
% 
% figure;
% eeg.plot_data('timelock');

% figure;
% bf.plot({'brain','skull','scalp','fiducials'});

figure;
bf.plot_scatter([]);
bf.plot_anatomical('method','slice');

figure;
bf.plot_moment('2d-all');
figure;
bf.plot_moment('2d-top');
figure;
bf.plot_moment('1d-top');
