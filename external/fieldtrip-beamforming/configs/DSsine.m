% DSsine

curdir = pwd;
[srcdir,~,~] = fileparts(mfilename('fullpath'));
if ~isequal(curdir,srcdir)
    cd(srcdir);
end

unit = 'mm';
if isequal(unit, 'cm')
    scale = 0.1; % for cm
elseif isequal(unit, 'mm')
    scale = 1; % for mm
else
    error(['ftb:' mfilename],...
        'unknown unit %s', unit);
end

k = 1;
dip(k).pos = scale*[-50 -10 50]; % mm
dip(k).mom = dip(k).pos/norm(dip(k).pos);

nsamples = 1000;
trials = 1;
fsample = 250; %Hz
triallength = nsamples/fsample;

cfg = [];
cfg.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
cfg.ft_dipolesimulation.dip.mom = [dip(1).mom]';
cfg.ft_dipolesimulation.dip.unit = unit;
cfg.ft_dipolesimulation.dip.frequency = 10;
cfg.ft_dipolesimulation.dip.phase = 0;
cfg.ft_dipolesimulation.dip.amplitude = 1*70;
cfg.ft_dipolesimulation.fsample = fsample;
cfg.ft_dipolesimulation.ntrials = trials;
cfg.ft_dipolesimulation.triallength = triallength;
cfg.ft_dipolesimulation.absnoise = 0.01;

cfg.ft_timelockanalysis.covariance = 'yes';
cfg.ft_timelockanalysis.covariancewindow = 'all';
cfg.ft_timelockanalysis.keeptrials = 'no';
cfg.ft_timelockanalysis.removemean = 'yes';

save('DSsine.mat','cfg');

cd(curdir);