function plot_pdc_dynamic_summary(data,varargin)

p = inputParser();
fs_default = 1;
addRequired(p,'data',@isstruct);
addParameter(p,'w_max',0.5,@(x) isnumeric(x) && x <= 0.5); % not sure about this
addParameter(p,'fs',fs_default,@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
parse(p,data,varargin{:});

dims = size(data.pdc);
ndims = length(dims);
if ndims == 4
    % dynamic pdc
    [nsamples,nchannels,~,nfreqs]=size(data.pdc); 
else
    error('requires dynamic pdc data');
end

fs = p.Results.fs;

w_max = p.Results.w_max;
w = 0:fs/(2*nfreqs):w_max-fs/(2*nfreqs);
nPlotPoints = length(w);

data_plot = zeros(nchannels, nchannels);
for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            
            data_temp = abs(squeeze(data.pdc(:,i,j,1:nPlotPoints))');
            
            data_plot(j,i) = sum(data_temp(:));
        end
        
    end
end

title('PDC - Channel Pair Summary');
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