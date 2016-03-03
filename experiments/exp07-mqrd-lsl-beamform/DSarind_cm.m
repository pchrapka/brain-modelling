function DSarind_cm()
% DSarind_cm

[srcdir,~,~] = fileparts(mfilename('fullpath'));

unit = 'cm';

k = 1;
pos(k,:) = [-5 -1 5]; % cm
mom(k,:) = pos(k,:)/norm(pos(k,:));
k = k+1;
pos(k,:) = [-4 4 7]; % cm
% mom(k,:) = pos(k,:)/norm(pos(k,:));
mom(k,:) = [0 0 1];
% k = k+1;
% pos(k,:) = [10 2 4]; % cm
% % mom(k,:) = pos(k,:)/norm(pos(k,:));
% mom(k,:) = [0 1 1];

nsamples = 1000;
trials = 1;
fsample = 250; %Hz
triallength = nsamples/fsample;

cfg = [];
cfg.ft_dipolesimulation.dip.pos = pos; % in cm
cfg.ft_dipolesimulation.dip.mom = mom';
cfg.ft_dipolesimulation.dip.unit = unit;
cfg.ft_dipolesimulation.dip.frequency = [10, 5];
cfg.ft_dipolesimulation.dip.phase = [0, pi/2];
% cfg.ft_dipolesimulation.dip.frequency = [10, 5, 20];
% cfg.ft_dipolesimulation.dip.phase = [0, pi/2, pi/3];
cfg.ft_dipolesimulation.dip.amplitude = 1*70*ones(1,k);
cfg.ft_dipolesimulation.fsample = fsample;
cfg.ft_dipolesimulation.ntrials = trials;
cfg.ft_dipolesimulation.triallength = triallength;
cfg.ft_dipolesimulation.absnoise = 0.01;

cfg.ft_timelockanalysis.covariance = 'yes';
cfg.ft_timelockanalysis.covariancewindow = 'all';
cfg.ft_timelockanalysis.keeptrials = 'no';
cfg.ft_timelockanalysis.removemean = 'yes';

save(fullfile(srcdir,'DSarind-cm.mat'),'cfg');

end