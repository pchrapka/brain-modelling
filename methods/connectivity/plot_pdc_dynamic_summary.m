function plot_pdc_dynamic_summary(data,varargin)

p = inputParser();
fs_default = 1;
addRequired(p,'data',@isstruct);
addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2)); % not sure about this
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

if p.Results.w(1) < 0 || p.Results.w(2) > 0.5
    disp(p.Results.w);
    error('w range too wide should be between [0 0.5]');
end
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= p.Results.w(1)) & (w <= p.Results.w(2));
f = w(w_idx)*fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

data_plot = zeros(nchannels, nchannels);
for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            
            data_temp = abs(squeeze(data.pdc(:,i,j,freq_idx))');
            
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
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',tick_labels,...
        'Ytick',ticks,...
        'YtickLabel',tick_labels);
else
    set(gca,...
        'Xtick',ticks,...
        'XtickLabel',p.Results.ChannelLabels,...
        'Ytick',ticks,...
        'YtickLabel',p.Results.ChannelLabels);
end

end