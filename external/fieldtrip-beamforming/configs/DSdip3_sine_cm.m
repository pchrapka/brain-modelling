function DSdip3_sine_cm()
% DSdip3_sine_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

unit = 'cm';

k = 1;
pos(k,:) = [-5 -1 5]; % cm
mom(k,:) = pos(k,:)/norm(pos(k,:));
k = k+1;
pos(k,:) = [-4 4 7]; % cm
% mom(k,:) = pos(k,:)/norm(pos(k,:));
mom(k,:) = [0 0 1];
k = k+1;
pos(k,:) = [10 2 4]; % cm
% % mom(k,:) = pos(k,:)/norm(pos(k,:));
mom(k,:) = [0 1 1];

trials = 1;
fsample = 250; %Hz
nsamples = fsample;
triallength = nsamples/fsample;

cfg = [];
cfg.ft_dipolesimulation.dip.pos = pos; % in cm
cfg.ft_dipolesimulation.dip.mom = mom';
cfg.ft_dipolesimulation.dip.unit = unit;
if size(pos,1) == 1
    cfg.ft_dipolesimulation.dip.frequency = 10;
    cfg.ft_dipolesimulation.dip.phase = 0;
    cfg.ft_dipolesimulation.dip.amplitude = 1;
elseif size(pos,1) == 2
    cfg.ft_dipolesimulation.dip.frequency = [10, 5];
    cfg.ft_dipolesimulation.dip.phase = [0, pi/3];
    cfg.ft_dipolesimulation.dip.amplitude = [1 1];
elseif size(pos,1) == 3
    cfg.ft_dipolesimulation.dip.frequency = [10, 5, 20];
    cfg.ft_dipolesimulation.dip.phase = [0, pi/2, pi/3];
    cfg.ft_dipolesimulation.dip.amplitude = [1 1 1];
end
cfg.ft_dipolesimulation.fsample = fsample;
cfg.ft_dipolesimulation.ntrials = trials;
cfg.ft_dipolesimulation.triallength = triallength;
cfg.ft_dipolesimulation.relnoise = 0.1;

cfg.ft_timelockanalysis.covariance = 'yes';
cfg.ft_timelockanalysis.covariancewindow = 'all';
cfg.ft_timelockanalysis.keeptrials = 'no';
cfg.ft_timelockanalysis.removemean = 'yes';

save(fullfile(srcdir,'DSdip3-sine-cm.mat'),'cfg');

end