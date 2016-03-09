%% test_headmodels

close all;

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end


%% Create analysis step objects

config_dir = fullfile('..','configs');

% MRI
params_mri = 'MRIS01.mat';
m = ftb.MRI(params_mri,'S01');

% Headmodel
params_hm = {...
    'HMbemcp-cm.mat',...
    'HMconcsphere-cm.mat',...
    'HMdipoli-cm.mat',...
    'HMopenmeeg-cm.mat'...
    };

for i=1:length(params_hm)
    name_hm = strrep(params_hm{i},'HM','');
    name_hm = strrep(name_hm,'.mat','');
    hm{i} = ftb.Headmodel(params_hm{i},name_hm);

    params_e = 'E128-cm.mat';
    e{i} = ftb.Electrodes(params_e,'128-cm');
    e{i}.set_fiducial_channels('NAS','FidNz','LPA','FidT9','RPA','FidT10');
    e{i}.force = false;

    % 1cm normalized
    params_lf = 'L1cm-norm.mat';
    lf{i} = ftb.Leadfield(params_lf,'1cm-norm');
    
    % % 1cm unnormalized
    % params_lf = 'L1cm.mat';
    % lf{i} = ftb.Leadfield(params_lf,'1cm');

    lf{i}.force = false;
    
    % multiple sources
    DSdip3_sine_cm();
    params_dsim = 'DSdip3-sine-cm.mat';
    dsim{i} = ftb.DipoleSim(params_dsim,'dip3-sine-cm');
    dsim{i}.force = false;
    
    params_bf = 'BFlcmv.mat';
    bf{i} = ftb.Beamformer(params_bf,'lcmv');
    
    %% Set up beamformer analysis
    out_folder = 'output';
    if ~exist(out_folder,'dir')
        mkdir(out_folder);
    end
    
    analysis{i} = ftb.AnalysisBeamformer(out_folder);
    
    % add steps
    analysis{i}.add(m);
    analysis{i}.add(hm{i});
    analysis{i}.add(e{i});
    analysis{i}.add(lf{i});
    analysis{i}.add(dsim{i});
    analysis{i}.add(bf{i});
    analysis{i}.init();
    analysis{i}.process();
    
    %% Plot
    figure;
    bf{i}.plot({'brain','skull','scalp','fiducials','dipole'});
    title(name_hm);
    figure;
    bf{i}.plot_scatter([]);
    title(name_hm);
    % bf.plot_anatomical();
end