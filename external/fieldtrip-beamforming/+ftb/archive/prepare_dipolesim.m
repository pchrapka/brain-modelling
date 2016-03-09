function cfg = prepare_dipolesim(stage)
%
%   stage.headmodel
%   stage.electrodes
%   stage.dipolesim

unit = 'mm';
if isequal(unit, 'cm')
    scale = 0.1; % for cm
elseif isequal(unit, 'mm')
    scale = 1; % for mm
else
    error(['ftb:' mfilename],...
        'unknown unit %s', unit);
end

cfg = [];
cfg.force = false;
cfg.stage.headmodel = stage.headmodel;
cfg.stage.electrodes = stage.electrodes;
cfg.stage.dipolesim = stage.dipolesim;

% Set up electrode config
switch stage.dipolesim
    case 'SM1snr0'
        % Multiple sources, 2 sinusoidal
        
        k = 1;
        dip(k).pos = scale*[-50 -10 50];% mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        k = k+1;
        dip(k).pos = scale*[0 -50 50];% mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 100;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        % Signal configuration
        cfgsig = [];
        cfgsig.fsample = fsample;
        cfgsig.ntrials = trials;
        cfgsig.triallength = triallength;
        cfgsig.type = 'erp';
        cfgsig.amp = 1;
        cfgsig.freq = 10;
        cfgsig.pos = 120;
        cfgsig.jitter = 5;
        
        % Interference configuration
        cfgint = [];
        cfgint.fsample = fsample;
        cfgint.ntrials = trials;
        cfgint.triallength = triallength;
        cfgint.type = 'erp';
        cfgint.amp = 1;
        cfgint.freq = 10;
        cfgint.pos = 120;
        cfgint.jitter = 5;
        cfgint.pos = 124;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        % cfg.signal.ft_dipolesimulation.dip.signal = signal;
        
        cfg.interference.snr = snr;
        cfg.interference.ft_dipolesignal = cfgint;
        cfg.interference.ft_dipolesimulation.dip.pos = [dip(2).pos]; % in cm?
        cfg.interference.ft_dipolesimulation.dip.mom = [dip(2).mom]';
        cfg.interference.ft_dipolesimulation.dip.unit = unit;
        % cfg.interference.ft_dipolesimulation.dip.signal = interference;
        
        cfg.ft_dipolesimulationnoise.fsample = fsample;
        cfg.ft_dipolesimulationnoise.ntrials = trials;
        cfg.ft_dipolesimulationnoise.triallength = triallength;
        cfg.ft_dipolesimulationnoise.power = 1;
        
    case 'SS1snr0'
        % sinusoidal signal, no interference
        
        k = 1;
        dip(k).pos = scale*[-50 -10 50]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = 10;
        cfg.signal.ft_dipolesimulation.dip.phase = 0;
        cfg.signal.ft_dipolesimulation.dip.amplitude = 1*70;
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.absnoise = 0.01;
        
    case 'SS1'
        % sinusoidal signal, no interference
        
        k = 1;
        dip(k).pos = scale*[-50 -10 50]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = 10;
        cfg.signal.ft_dipolesimulation.dip.phase = 0;
        cfg.signal.ft_dipolesimulation.dip.amplitude = 1;
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.relnoise = 0.1;
        
    case 'SM1'
        % sinusoidal signal, no interference
        
        k = 1;
        dip(k).pos = scale*[-50 -10 50]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        k = k+1;
        dip(k).pos = scale*[0 -50 50]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos; dip(2).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom; dip(2).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = [10 15];
        cfg.signal.ft_dipolesimulation.dip.phase = [0 0];
        cfg.signal.ft_dipolesimulation.dip.amplitude = [1 1];
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.relnoise = 0.1;
        
    case 'SS2snr0'
        % sinusoidal signal, no interference
        
        k = 1;
        dip(k).pos = scale*[-40 30 80]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = 15;
        cfg.signal.ft_dipolesimulation.dip.phase = 0;
        cfg.signal.ft_dipolesimulation.dip.amplitude = 1*70;
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.absnoise = 0.01;
        
    case 'SS2'
        % sinusoidal signal, no interference
        
        k = 1;
        dip(k).pos = scale*[-40 30 80]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = 15;
        cfg.signal.ft_dipolesimulation.dip.phase = 0;
        cfg.signal.ft_dipolesimulation.dip.amplitude = 1;
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.relnoise = 0.1;
        
    case 'SM2'
        % two sinusoidal signals, no interference
        
        k = 1;
        dip(k).pos = scale*[-40 30 80]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        k = k+1;
        dip(k).pos = scale*[0 -50 50]; % mm
        dip(k).mom = dip(k).pos/norm(dip(k).pos);
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        snr = 0; % use the same snr for both signal and interference
        
        cfg.signal.snr = snr;
        % cfg.signal.ft_dipolesignal = cfgsig;
        cfg.signal.ft_dipolesimulation.dip.pos = [dip(1).pos; dip(2).pos]; % in cm?
        cfg.signal.ft_dipolesimulation.dip.mom = [dip(1).mom; dip(2).mom]';
        cfg.signal.ft_dipolesimulation.dip.unit = unit;
        cfg.signal.ft_dipolesimulation.dip.frequency = [10 15];
        cfg.signal.ft_dipolesimulation.dip.phase = [0 0];
        cfg.signal.ft_dipolesimulation.dip.amplitude = [1 1];
        cfg.signal.ft_dipolesimulation.fsample = fsample;
        cfg.signal.ft_dipolesimulation.ntrials = trials;
        cfg.signal.ft_dipolesimulation.triallength = triallength;
        cfg.signal.ft_dipolesimulation.relnoise = 0.1;

    case 'SNabs0-01'
        % noise
        % FIXME check if a default dipole is added
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        cfg.signal.ft_dipolesimulation.signal = {zeros(triallength*fsample,1)};
        cfg.signal.ft_dipolesimulation.absnoise = 0.01;
        
    case 'SNabs0-1'
        % noise
        % FIXME check if a default dipole is added
        
        nsamples = 1000;
        trials = 1;
        fsample = 250; %Hz
        triallength = nsamples/fsample;
        
        cfg.signal.ft_dipolesimulation.signal = {zeros(triallength*fsample,1)};
        cfg.signal.ft_dipolesimulation.absnoise = 0.1;
        
    otherwise
        error(['ftb:' mfilename],...
            'unknown dipolesim %s', stage.dipolesim);
end

end

