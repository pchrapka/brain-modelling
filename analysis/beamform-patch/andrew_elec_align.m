%% andrew_elec_align

pipeline = build_pipeline_beamformer(paramsbf_sd_andrew(4,10,'std'));

step_final = pipeline.steps{end};

obj_mri = step_final.get_dep('ftb.MRI');
obj_hm = step_final.get_dep('ftb.Headmodel');
obj_elec = step_final.get_dep('ftb.Electrodes');

%% align electrodes

[pos,names] = obj_mri.get_mri_fiducials();

fid = [];
% create a structure similar to a template set of electrodes
fid.chanpos = pos;
% same labels as in elec, same order as in
% get_mri_fiducials
names = lower(names);
for i=1:length(names)
    fid.label{i} = obj_elec.(['fid_' names{i}]);
end
fid.unit = 'mm'; % same units as mri

cfg = [];
cfg.method = 'template';
cfg.warp = 'globalrescale';
% cfg.warp = 'nonlin1';
cfg.target = fid;
cfg.casesensitive = 'no';
cfg.elec = ftb.util.loadvar(obj_elec.elec);

sens_aligned = ft_electroderealign(cfg);


%% plot

% plot electrodes pre-alignment
figure;
obj_elec.plot({'fiducials','scalp','electrodes','electrodes-labels'});

% plot electrodes post-alignment
figure;
obj_elec.plot({'fiducials','scalp'});

unit = 'mm';
sens_aligned = ft_convert_units(sens_aligned, unit);
ft_plot_sens(sens_aligned,'style','ok','label','label');