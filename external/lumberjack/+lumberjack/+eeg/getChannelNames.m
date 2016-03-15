function names = getChannelNames(numChannels)
% GETCHANNELNAMES Returns the channel names for a certain EEG configuration
%   NAMES = GETCHANNELNAMES(NUMCHANNELS) Returns the channel names for an
%   EEG configuration specified by NUMCHANNELS

if(numChannels == 16)
    names = {...
        'Fp1','Fp2','F3','F4','F7','F8','T3','T4',...
        'T5','T6','C3','C4','P3','P4','O1','O2'};
else
    error('Specify new names');
end