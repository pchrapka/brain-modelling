function setYTickLabels2ChannelNames( n, spacing )
%SETYTICKLABELS2CHANNELNAMES Sets the y tick labels of the current axes to
%the actual channel names
%   SETYTICKLABELS2CHANNELNAMES(N, SPACING) sets the y tick labels of the
%   current axes to the actual channel names and spreads them out by the
%   amount specified by SPACING. N specifies the number of channels.

numChannels = n;

switch numChannels
    case 16
        % Set the ylabels
        % Set ticks to the center of each channel
        yTicks = (0:1:(numChannels-1))*spacing;
        set(gca,'YTick',yTicks);
        % Get new y axis tick labels
        yTickLabels = fliplr(...
            lumberjack.eeg.getChannelNames(numChannels));
        set(gca,'YTickLabel',yTickLabels);
    case 17
        % Adds the avg label at the bottom
        % Set the ylabels
        % Set ticks to the center of each channel
        yTicks = (0:1:(numChannels-1))*spacing;
        set(gca,'YTick',yTicks);
        % Get new y axis tick labels
        yTickLabels = ['Avg',fliplr(...
            lumberjack.eeg.getChannelNames(numChannels-1))];
        set(gca,'YTickLabel',yTickLabels);
    otherwise
        error('Invalid number of channels');
end
        

end

