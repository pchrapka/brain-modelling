function chanunit = ft_chanunit(input, desired)

% FT_CHANUNIT is a helper function that tries to determine the physical
% units of each channel. In case the type of channel is not detected, it
% will return 'unknown' for that channel.
%
% Use as
%   unit = ft_chanunit(hdr)
% or as
%   unit = ft_chanunit(hdr, desired)
%
% If the desired unit is not specified as second input argument, this
% function returns a Nchan*1 cell array with a string describing the
% physical units of each channel, or 'unknown' if those cannot be
% determined.
%
% If the desired unit is specified as second input argument, this function
% returns a Nchan*1 boolean vector with "true" for the channels that match
% the desired physical units and "false" for the ones that do not match.
%
% The specification of the channel units depends on the acquisition system,
% for example the neuromag306 system includes channel with the following
% units: uV, T and T/cm.
%
% See also FT_CHANTYPE

% Copyright (C) 2011-2013, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_chanunit.m 10516 2015-07-04 13:06:48Z roboos $

% these are for remembering the type on subsequent calls with the same input arguments
persistent previous_argin previous_argout

if nargin<2
  desired = [];
end

% determine the type of input, this is handled similarly as in FT_CHANTYPE
isheader =  isa(input, 'struct') && isfield(input, 'label') && isfield(input, 'Fs');
islabel  =  isa(input, 'cell')   && isa(input{1}, 'char');
isgrad   =  isa(input, 'struct') && isfield(input, 'pnt') && isfield(input, 'ori');
isgrad   = (isa(input, 'struct') && isfield(input, 'coilpos')) || isgrad;
isgrad   = (isa(input, 'struct') && isfield(input, 'coilori')) || isgrad;
iselec   =  isa(input, 'struct') && isfield(input, 'pnt') && ~isfield(input, 'ori');
iselec   = (isa(input, 'struct') && isfield(input, 'elecpos')) || iselec;

if isheader
  % this speeds up the caching in real-time applications
  input.nSamples = 0;
end

current_argin = {input, desired};
if isequal(current_argin, previous_argin)
  % don't do the type detection again, but return the previous output from cache
  chanunit = previous_argout{1};
  return
end

if isheader
  label = input.label;
  numchan = length(label);
elseif isgrad
  label   = input.label;
  numchan = length(label);
elseif iselec
  label   = input.label;
  numchan = length(label);
elseif islabel
  label   = input;
  numchan = length(label);
elseif isfield(input, 'label')
  % this is a last resort: I don't know what it is, but perhaps the labels are informative
  label   = input.label;
  numchan = length(label);
else
  error('the input that was provided to this function cannot be deciphered');
end

% start with unknown unit for all channels
chanunit = repmat({'unknown'}, size(input.label));

if ft_senstype(input, 'unknown')
  % don't bother doing all subsequent checks to determine the type of sensor array
  
elseif isheader && ft_senstype(input, 'eeg')
  % until now in all stand-alone EEG systems examined the data was in uV
  chanunit(strcmp('eeg',              input.chantype)) = {'uV'};
  
elseif isheader && (ft_senstype(input, 'neuromag') || ft_senstype(input, 'babysquid74')) && issubfield(input, 'orig.chs')
  for i = 1:numchan % make a cell array of units for each channel
    switch input.orig.chs(i).unit
      case 201 % defined as constants by MNE, see p. 217 of MNE manual
        chanunit{i} = 'T/m';
      case 112
        chanunit{i} = 'T';
      case 107
        chanunit{i} = 'V';
      case 202
        chanunit{i} = 'Am';
      otherwise
        chanunit{i} = 'unknown';
    end
  end
  
elseif iselec && isfield(input, 'chantype')
  % electrode definitions are expressed in SI units, i.e. V
  chanunit(strcmp('eeg',              input.chantype)) = {'V'};

elseif isgrad && (ft_senstype(input, 'neuromag') || ft_senstype(input, 'babysquid74')) && isfield(input, 'chantype')
  % look at the type of the channels
  chanunit(strcmp('eeg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('emg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('eog',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('ecg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('megmag',           input.chantype)) = {'T'};
  chanunit(strcmp('megaxial',         input.chantype)) = {'T'}; % applies to BabySQUID system
  
  if isfield(input, 'tra')
    if all(sum(abs(input.tra),2)==1 | sum(abs(input.tra),2)==2)
      % it is not scaled with distance
      chanunit(strcmp('megplanar',        input.chantype)) = {'T'};
    else
      % it is scaled with distance
      if isfield(input, 'unit')
        assumption = sprintf('T/%s', input.unit);
        chanunit(strcmp('megplanar',        input.chantype)) = {assumption};
        warning('assuming that planar channel units are %s', assumption);
      else
        chanunit(strcmp('megplanar',        input.chantype)) = {'unknown'};
        warning('cannot determine the units for the planar MEG channels');
      end
    end
  end
  
elseif (ft_senstype(input, 'neuromag') || ft_senstype(input, 'babysquid74')) && isfield(input, 'chantype')
  % determine the units only based on the channel name and type
  chanunit(strcmp('eeg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('emg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('eog',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('ecg',              input.chantype)) = {'unknown'}; % FIXME
  chanunit(strcmp('megmag',           input.chantype)) = {'T'};
  chanunit(strcmp('megaxial',         input.chantype)) = {'T'}; % applies to BabySQUID system
  
  if isfield(input, 'unit')
    assumption = sprintf('T/%s', input.unit);
    chanunit(strcmp('megplanar',        input.chantype)) = {assumption};
    warning('assuming that planar channel units are %s, consistent with the geometrical units', assumption);
  else
    chanunit(strcmp('megplanar',        input.chantype)) = {'unknown'};
    warning('cannot determine the units for the planar MEG channels');
  end
  
elseif ft_senstype(input, 'ctf') && isfield(input, 'chantype')
  chanunit(strcmp('eeg',              input.chantype)) = {'V'};
  chanunit(strcmp('emg',              input.chantype)) = {'V'};
  chanunit(strcmp('eog',              input.chantype)) = {'V'};
  chanunit(strcmp('ecg',              input.chantype)) = {'V'};
  chanunit(strcmp('meggrad',          input.chantype)) = {'T'};
  chanunit(strcmp('refmag',           input.chantype)) = {'T'};
  chanunit(strcmp('refgrad',          input.chantype)) = {'T'};
  chanunit(strcmp('clock',            input.chantype)) = {'s'}; % seconds
  
elseif ft_senstype(input, 'yokogawa') && isfield(input, 'chantype')
  chanunit(strcmp('meggrad',          input.chantype)) = {'T'};
  chanunit(strcmp('megplanar',        input.chantype)) = {'T'}; % I am not sure whether it is T or T/m
  
elseif ft_senstype(input, 'bti') && isfield(input, 'chantype')
  chanunit(strcmp('meg',                 input.chantype)) = {'T'}; % this was the channel type until approx. 2 November 2012, see http://bugzilla.fcdonders.nl/show_bug.cgi?id=1807
  chanunit(strcmp('megmag',              input.chantype)) = {'T'}; % applies for magnetometer 4D/BTi systems
  chanunit(strcmp('eeg',                 input.chantype)) = {'V'}; % seems to be true for the example I have (VL)
  chanunit(strcmp('meggrad',             input.chantype)) = {'T'}; % this is the plain difference in the field at the two coils, i.e. in T
  chanunit(strcmp('refmag',              input.chantype)) = {'T'};
  chanunit(strcmp('refgrad',             input.chantype)) = {'T'};
  chanunit(strcmp('ref',                 input.chantype)) = {'T'};
  
elseif ft_senstype(input, 'itab') && isfield(input, 'chantype')
  chanunit(strcmp('megmag',              input.chantype)) = {'T'};
  
end % if senstype

% ensure that it is a column vector
chanunit = chanunit(:);

if nargin>1
  chanunit = strcmp(desired, chanunit);
end

% remember the current input and output arguments, so that they can be
% reused on a subsequent call in case the same input argument is given
current_argout = {chanunit};
previous_argin  = current_argin;
previous_argout = current_argout;