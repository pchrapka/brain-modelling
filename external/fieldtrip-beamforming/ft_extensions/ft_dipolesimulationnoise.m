function [simulated] = ft_dipolesimulationnoise(cfg)

% FT_DIPOLESIMULATION computes the field or potential of a simulated dipole
% and returns a datastructure identical to the FT_PREPROCESSING function.
%
% Use as
%   data = ft_dipolesimulationnoise(cfg)
%
%   cfg.ntrials          number of trials
%   cfg.triallength      time in seconds
%   cfg.fsample          sampling frequency in Hz
%
% Random white noise can be added to the data in each trial, either by
% specifying an absolute or a relative noise level
%   cfg.relnoise    = add noise with level relative to simulated signal
%   cfg.absnoise    = add noise with absolute level
%
% Optional input arguments are
%   cfg.channel    = Nx1 cell-array with selection of channels (default = 'all'),
%                    see FT_CHANNELSELECTION for details
%   cfg.dipoleunit = units for dipole amplitude (default nA*m)
%   cfg.chanunit   = units for the channel data
%
% The volume conduction model of the head should be specified as
%   cfg.vol           = structure with volume conduction model, see FT_PREPARE_HEADMODEL
%   cfg.hdmfile       = name of file containing the volume conduction model, see FT_READ_VOL
%
% The EEG or MEG sensor positions should be specified as
%   cfg.elec          = structure with electrode positions, see FT_DATATYPE_SENS
%   cfg.grad          = structure with gradiometer definition, see FT_DATATYPE_SENS
%   cfg.elecfile      = name of file containing the electrode positions, see FT_READ_SENS
%   cfg.gradfile      = name of file containing the gradiometer definition, see FT_READ_SENS
%
% See also FT_SOURCEANALYSIS, FT_SOURCESTATISTICS, FT_SOURCEPLOT,
% FT_PREPARE_VOL_SENS

% Undocumented local options
% cfg.feedback
% cfg.previous
% cfg.version

% do the general setup of the function
ft_defaults
ft_preamble init
ft_preamble provenance
ft_preamble trackconfig
ft_preamble debug

% the abort variable is set to true or false in ft_preamble_init
if abort
  return
end

% set the defaults
if ~isfield(cfg, 'fsample'),    cfg.fsample = 250;        end
if ~isfield(cfg, 'ntrials'),    cfg.ntrials = 20;         end
if ~isfield(cfg, 'power'),      cfg.power = 1;            end
if ~isfield(cfg, 'feedback'),   cfg.feedback = 'text';    end
if ~isfield(cfg, 'channel'),    cfg.channel = 'all';      end
if ~isfield(cfg, 'chanunit'),   cfg.chanunit = {};        end

cfg = ft_checkconfig(cfg);

Ntrials  = cfg.ntrials;
nsamples = round(cfg.triallength*cfg.fsample);

% collect and preprocess the electrodes/gradiometer and head model
[vol, sens, cfg] = prepare_headmodel(cfg, []);

nchannels = length(sens.label);

if ft_senstype(sens, 'meg')
  simulated.grad = sens;
elseif ft_senstype(sens, 'meg')
  simulated.elec = sens;
end

ft_progress('init', cfg.feedback, 'computing simulated noise');
% add noise to the simulated data
for trial=1:Ntrials
    ft_progress(trial/Ntrials, 'computing simulated noise for trial %d\n', trial);
    
    trialnoise = zeros(nchannels,nsamples);
    for channel=1:nchannels
        % Generate noise for each channel
        trialnoise(channel,:) = phasereset.noise(...
            nsamples, 1, cfg.fsample);
        
        % Adjust the noise power
        % Calculate the current noise power
        noise_power = var(trialnoise(channel,:));
        % Calculate the adjustment
        alpha = cfg.power/noise_power;
        % Make the adjustment
        trialnoise(channel,:) = alpha*trialnoise(channel,:);
    end
    simulated.trial{trial} = trialnoise;
    simulated.time{trial}   = (0:(nsamples-1))/cfg.fsample;
end
ft_progress('close');

simulated.fsample = cfg.fsample;
simulated.label   = sens.label;

% do the general cleanup and bookkeeping at the end of the function
ft_postamble debug
ft_postamble trackconfig
ft_postamble provenance
ft_postamble history simulated
ft_postamble savevar simulated
