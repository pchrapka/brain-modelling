function plot_seed(obj,chseed,varargin)

obj.save_tag = [];

p = inputParser();
addRequired(p,'chseed',@isnumeric);
addParameter(p,'direction','outgoing',@(x) any(validatestring(x,{'outgoing','incoming'})));
% addParameter(p,'threshold',0.2,@(x) x >= 0 && x <= 1);
% addParameter(p,'save',false,@islogical);
% addParameter(p,'outdir','',@ischar);
parse(p,chseed,varargin{:});

obj.load();
[nsamples,nchannels,~,nfreqs] = size(obj.pdc);
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
% nfreqs_selected = sum(w_idx);
% threshold = p.Results.threshold_pct*nfreqs_selected;
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

data_plot = zeros(nchannels,nsamples);
yticklabel = cell(nchannels,1);
count = 1;
for i=1:nchannels
    switch p.Results.direction
        case 'outgoing'
            data_temp = squeeze(obj.pdc(:,i,p.Results.chseed,freq_idx));
            str_xlabel = 'from';
        case 'incoming'
            data_temp = squeeze(obj.pdc(:,p.Results.chseed,i,freq_idx));
            str_xlabel = 'to';
    end
    data_all = sum(data_temp(:));
    
    % only add to plot if the whole sum is not 0
    if data_all > 0
        % sum over frequencies
        data_plot(count,:) = sum(data_temp,2);
        if ~isempty(obj.labels)
            yticklabel{count} = obj.labels{i};
        else
            yticklabel{count} = sprintf('%d',i);
        end
        count = count + 1;
    end
end

data_plot = data_plot(1:count-1,:);
yticklabel = yticklabel(1:count-1,:);

clim = [0 1];
imagesc(data_plot,clim);
cmap = colormap(hot);
cmap = flip(cmap,1);
colormap(cmap);
colorbar();

ytick = 1:length(yticklabel);
set(gca,...
    'YTick', ytick, ...
    'YTickLabel', yticklabel,...
    'FontSize',10);

if ~isempty(obj.labels)
    label_seed = obj.labels{p.Results.chseed};
else
    label_seed = sprintf('%d',p.Results.chseed);
end

switch p.Results.direction
    case 'outgoing'
        str_xlabel = 'from';
        xlabel_string = sprintf('%s %s',str_xlabel,label_seed);
        ylabel('to');
        xlabel(xlabel_string);
        obj.save_tag = sprintf('-seed-out-j%d',p.Results.chseed);
    case 'incoming'
        str_xlabel = 'to';
        xlabel_string = sprintf('%s %d',str_xlabel,label_seed);
        ylabel('from');
        xlabel(xlabel_string);
        obj.save_tag = sprintf('-seed-in-i%d',p.Results.chseed);
end

end