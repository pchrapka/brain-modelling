function [cfg, artifact] = ft_artifact_threshold_partial(cfg, data)

% FT_ARTIFACT_THRESHOLD scans for trials in which the range, i.e. the minimum,
% the maximum or the range (min-max difference) of the signal in any
% channel exceeds a specified threshold.
%
% Use as
%   [cfg, artifact] = ft_artifact_threshold(cfg)
% with the configuration options
%   cfg.dataset     = string with the filename
% or
%   cfg.headerfile  = string with the filename
%   cfg.datafile    = string with the filename
%
% Alternatively you can use it as
%   [cfg, artifact] = ft_artifact_threshold(cfg, data)
%
% In both cases the configuration should also contain
%   cfg.trl        = structure that defines the data segments of interest, see FT_DEFINETRIAL
%   cfg.continuous = 'yes' or 'no' whether the file contains continuous data
%
% The following configuration options can be specified
%   cfg.artfctdef.threshold.channel   = cell-array with channel labels
%   cfg.artfctdef.threshold.bpfilter  = 'no' or 'yes'
%   cfg.artfctdef.threshold.bpfreq    = [0.3 30]
%   cfg.artfctdef.threshold.bpfiltord = 4
%
% The detection of artifacts is done according to the following settings,
% you should specify at least one of these thresholds
%   cfg.artfctdef.threshold.range     = value in uV/T, default  inf
%   cfg.artfctdef.threshold.min       = value in uV/T, default -inf
%   cfg.artfctdef.threshold.max       = value in uV/T, default  inf
%
% When cfg.artfctdef.threshold.range is used, the within-channel
% peak-to-peak range is checked against the specified maximum range (so not
% the overall range across channels).
%
% Contrary to the other artifact detection functions, this function
% will mark the whole trial as an artifact if the threshold is exceeded.
% Furthermore, this function does not support artifact- or filterpadding.
%
% To facilitate data-handling and distributed computing you can use
%   cfg.inputfile   =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%
% See also FT_REJECTARTIFACT, FT_ARTIFACT_CLIP, FT_ARTIFACT_ECG, FT_ARTIFACT_EOG,
% FT_ARTIFACT_JUMP, FT_ARTIFACT_MUSCLE, FT_ARTIFACT_THRESHOLD, FT_ARTIFACT_ZVALUE

revision = '';

% do the general setup of the function
ft_defaults
ft_preamble init
ft_preamble provenance
ft_preamble loadvar data

% the abort variable is set to true or false in ft_preamble_init
if abort
  return
end

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'renamed',    {'datatype', 'continuous'});
cfg = ft_checkconfig(cfg, 'renamedval', {'continuous', 'continuous', 'yes'});

% set default rejection parameters for clip artifacts if necessary
if ~isfield(cfg, 'artfctdef'),          cfg.artfctdef            = [];  end
if ~isfield(cfg.artfctdef,'threshold'), cfg.artfctdef.threshold  = [];  end
if ~isfield(cfg, 'headerformat'),       cfg.headerformat         = [];  end
if ~isfield(cfg, 'dataformat'),         cfg.dataformat           = [];  end

% copy the specific configuration for this function out of the master cfg
artfctdef = cfg.artfctdef.threshold;

% rename some cfg fields for backward compatibility
if isfield(artfctdef, 'sgn') && ~isfield(artfctdef, 'channel')
  artfctdef.channel = artfctdef.sgn;
  artfctdef         = rmfield(artfctdef, 'sgn');
end
if isfield(artfctdef, 'cutoff') && ~isfield(artfctdef, 'range')
  artfctdef.range = artfctdef.cutoff;
  artfctdef       = rmfield(artfctdef, 'cutoff');
end

if isfield(artfctdef,'range')
    error('range is not supported');
end

% set default preprocessing parameters if necessary
if ~isfield(artfctdef, 'channel'),   artfctdef.channel   = 'all';    end
if ~isfield(artfctdef, 'bpfilter'),  artfctdef.bpfilter  = 'yes';    end
if ~isfield(artfctdef, 'bpfreq'),    artfctdef.bpfreq    = [0.3 30]; end
if ~isfield(artfctdef, 'bpfiltord'), artfctdef.bpfiltord = 4;        end

% set the default artifact detection parameters
%if ~isfield(artfctdef, 'range'),    artfctdef.range = inf;           end
if ~isfield(artfctdef, 'min'),      artfctdef.min =  -inf;           end
if ~isfield(artfctdef, 'max'),      artfctdef.max =   inf;           end
if ~isfield(artfctdef, 'minacceptprct'),artfctdef.minacceptprct =   0.5; end
if ~isfield(artfctdef, 'nsections'),artfctdef.nsections = 1;         end

% the data is either passed into the function by the user or read from file with cfg.inputfile
hasdata = exist('data', 'var');

% read the header, or get it from the input data
if ~hasdata
  cfg = ft_checkconfig(cfg, 'dataset2files', 'yes');
  cfg = ft_checkconfig(cfg, 'required', {'headerfile', 'datafile'});
  hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
else
  % data given as input
  data = ft_checkdata(data, 'hassampleinfo', 'yes');
  cfg = ft_checkconfig(cfg, 'forbidden', {'dataset', 'headerfile', 'datafile'});
  hdr = ft_fetch_header(data);
end

% set default cfg.continuous
if ~isfield(cfg, 'continuous')
  if hdr.nTrials==1
    cfg.continuous = 'yes';
  else
    cfg.continuous = 'no';
  end
end

% get the remaining settings
numtrl      = size(cfg.trl,1);
channel     = ft_channelselection(artfctdef.channel, hdr.label);
channelindx = match_str(hdr.label,channel);
artifact    = [];

for trlop = 1:numtrl
  if hasdata
    dat = ft_fetch_data(data,        'header', hdr, 'begsample', cfg.trl(trlop,1), 'endsample', cfg.trl(trlop,2), 'chanindx', channelindx, 'checkboundary', strcmp(cfg.continuous, 'no'));
  else
    dat = ft_read_data(cfg.datafile, 'header', hdr, 'begsample', cfg.trl(trlop,1), 'endsample', cfg.trl(trlop,2), 'chanindx', channelindx, 'checkboundary', strcmp(cfg.continuous, 'no'), 'dataformat', cfg.dataformat);
  end
  dat = preproc(dat, channel, offset2time(cfg.trl(trlop,3), hdr.Fs, size(dat,2)), artfctdef);
  
  nsamples = size(dat,2);
  nsamples_sec = floor(nsamples/artfctdef.nsections);
  idx = [1 nsamples_sec];
  bad_section = false;
  for sec=1:artfctdef.nsections
      datsec = dat(:,idx(1):idx(2));
      
      datmin = false(size(datsec));
      if ~isempty(artfctdef.min)
          % get samples that exceed min threshold
          datmin = datsec < artfctdef.min;
      end
      
      datmax = false(size(datsec));
      if ~isempty(artfctdef.max)
          % get samples that exceed max threshold
          datmax = datsec > artfctdef.max;
      end
      
      % decide if artifact
      % combine conditions
      datcond = datmax | datmin;
      % count number of excessive samples
      datcond_count = sum(datcond,2);
      bad_chan = datcond_count >= ceil(artfctdef.minacceptprct*nsamples_sec);
      if any(bad_chan)
          fprintf('threshold artifact scanning: trial %d from %d, section %d exceeds min or max threshold\n', trlop, numtrl, sec);
          bad_section = true;
          break;
      end
      
      idx = idx + nsamples_sec;
  end
  
  if bad_section
      artifact(end+1,1:2) = cfg.trl(trlop,1:2);
  else
      fprintf('threshold artifact scanning: trial %d from %d is ok\n', trlop, numtrl);
  end
end

fprintf('detected %d artifacts\n', size(artifact,1));

% remember the details that were used here
cfg.artfctdef.threshold          = artfctdef;
cfg.artfctdef.threshold.trl      = cfg.trl;         % trialdefinition prior to rejection
cfg.artfctdef.threshold.channel  = channel;         % exact channels used for detection
cfg.artfctdef.threshold.artifact = artifact;        % detected artifacts

% do the general cleanup and bookkeeping at the end of the function
ft_postamble provenance
ft_postamble previous data

