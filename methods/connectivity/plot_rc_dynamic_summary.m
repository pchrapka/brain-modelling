function plot_rc_dynamic_summary(data,varargin)
%PLOT_RC_DYNAMIC_SUMMARY plots summary of dynamic reflection coefficients
%   PLOT_RC_DYNAMIC_SUMMARY(data,...) plots summary of dynamic reflection
%   coefficients
%
%   Input
%   -----
%   data (matrix)
%       reflection coefficients from LatticeTrace object, i.e. the Kf or Kb
%       field, [samples order channel channel]
%
%   Parameters
%   ----------

p = inputParser();
addRequired(p,'data',@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
% addParameter(p,'clim',[-1.2 1.2],@(x) isvector(x) || isequal(x,'none'));
% addParameter(p,'abs',false,@islogical);
% addParameter(p,'threshold','none',@(x) isscalar(x) || isequal(x,'none'));
parse(p,data,varargin{:});

dims = size(data);
ndims = length(dims);
if ndims == 4
    %nsamples = dims(1);
    if dims(2) == dims(3)
        format_orig = 3;
        %norder = dims(4);
        nchannels = dims(2);
    elseif dims(3) == dims(4)
        format_orig = 1;
        %norder = dims(2);
        nchannels = dims(4);
    else
        error('unknown coefficient format');
    end
else
    error('requires dynamic rc data');
end

% transform data based on parameters
% data = transform_data(data,p.Results);

h = [];

data_plot = zeros(nchannels, nchannels);
for j=1:nchannels
    for i=1:nchannels
        
        switch format_orig
            case 3
                data_temp = squeeze(data(:,i,j,:))';
            case 1
                data_temp = squeeze(data(:,:,i,j))';
        end
        
        data_plot(j,i) = sum(abs(data_temp(:)));
    end
end

title('Reflection Coefficient - Channel Pair Summary');
imagesc(data_plot);
colorbar();
xlabel('Channels');
ylabel('Channels');

ticks = 1:nchannels;
if isempty(p.Results.ChannelLabels)
    tick_labels = cell(nchannels,1);
    for i=1:nchannels
        tick_labels{i} = num2str(i);
    end
    set(h,...
        'Xtick',ticks,...
        'XtickLabel',tick_labels,...
        'Ytick',ticks,...
        'YtickLabel',tick_labels);
else
    set(h,...
        'Xtick',ticks,...
        'XtickLabel',p.Results.ChannelLabels,...
        'Ytick',ticks,...
        'YtickLabel',p.Results.ChannelLabels);
end

end