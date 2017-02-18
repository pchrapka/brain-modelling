function plot_seed(obj,chseed,varargin)

p = inputParser();
addRequired(p,'chseed',@isnumeric);
addParameter(p,'direction','outgoing',@(x) any(validatestring(x,{'outgoing','incoming'})));
addParameter(p,'threshold',0.05,@(x) x >= 0 && x <= 1);
% addParameter(p,'save',false,@islogical);
% addParameter(p,'outdir','',@ischar);
parse(p,chseed,varargin{:});

obj.save_tag = [];
obj.load();
obj.check_info();

[nsamples,nchannels,~,nfreqs] = size(obj.pdc);
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
% nfreqs_selected = sum(w_idx);
% threshold = p.Results.threshold_pct*nfreqs_selected;
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

label_seed = obj.info.label{p.Results.chseed};

data_plot = zeros(nchannels,nsamples);
yticklabel = cell(nchannels,1);
count = 1;
for i=1:nchannels
    if i == p.Results.chseed
        % skip the diagonals, not informative
        continue;
    end
    
    switch p.Results.direction
        case 'outgoing'
            data_temp = squeeze(obj.pdc(:,i,p.Results.chseed,freq_idx));
        case 'incoming'
            data_temp = squeeze(obj.pdc(:,p.Results.chseed,i,freq_idx));
    end
    
    % threshold data
    data_all = data_temp(data_temp > p.Results.threshold);
    data_all = sum(data_all(:));
    
    % only add to plot if the whole sum is not 0
    if data_all > 0
        % sum over frequencies
        data_plot(i,:) = sum(data_temp,2);
        yticklabel{i} = obj.info.label{i};
    end
end

idx_empty = cellfun(@isempty,yticklabel,'UniformOutput',true);

if sum(~idx_empty) == 0
    fprintf('%s: no connections for %s\n',mfilename,label_seed);
    return;
end

% sort by hemisphere, region, angle
idx_sort = obj.sort_channels();
idx_sort = idx_sort(:);

% sort the data
data_plot = data_plot(idx_sort,:);
yticklabel = yticklabel(idx_sort,:);
idx_empty = idx_empty(idx_sort,:);

% remove empty entries
data_plot(idx_empty,:) = [];
yticklabel(idx_empty,:) = [];

figure;
if ~isempty(obj.info.region)
    ax2 = gca;
    set(ax2,'Visible','off');
    ax1_pos = get(ax2,'Position');
    ax1_offset = 0.2;
    ax1_pos(1) = ax1_pos(1) + ax1_offset;
    ax1_pos(3) = ax1_pos(3) - ax1_offset;
    ax1 = axes('Position',ax1_pos);
else
    ax1 = gca;
end
axes(ax1);

clim = [0 1];
imagesc(data_plot,clim);
cmap = colormap(hot);
cmap = flipdim(cmap,1);
colormap(cmap);
colorbar();

% add left axis with channel labels
ytick = 1:length(yticklabel);
set(gca,...
    'YTick', ytick, ...
    'YTickLabel', yticklabel,...
    'FontSize',10);

if ~isempty(obj.info.region)
    set(ax2,'YLim',get(ax1,'YLim'),'YDir',get(ax1,'YDir'));
    axes(ax2);
    xlim([0 1]);
    
    % set up colors
    max_regions = max(obj.info.region_order);
    cmap_cur = colormap();
    cmap = colormap(jet);
    colormap(cmap_cur);
    ncolors = size(cmap,1);
    % convert region to pecentage
    region_pct = obj.info.region_order/max_regions;
    % get color index in cmap
    color_idx = ceil(ncolors*region_pct);
    % get colors for each region
    colors = cmap(color_idx,:);
    
    % sort and remove empty
    colors = colors(idx_sort,:);
    colors(idx_empty,:) = [];
        
    % add extra labels with region labels
    % sort and remove empty
    regions = obj.info.region(idx_sort);
    regions(idx_empty) = [];
    
    %ax_pos = axis(ax2);
    nregions = length(regions);
    region1 = 1;
    offset = 0.5;
    ytick_inc = ytick(2)-ytick(1);
    for i=1:nregions
        if i == nregions
            region2 = 1;
        else
            region2 = i+1;
        end
        % find the region boundary
        if i~=nregions && isequal(regions{region1},regions{region2})
            continue;
        end
        
        % found next region
        
        region_offset = ax1_offset/3;
        
        % add line
        x = region_offset*ones(2,1);
        y = [ytick(region1); ytick(region2)] - ytick_inc/2;
        if y(2) < y(1)
            % fix rollover
            y(2) = max(ytick) + ytick_inc/2;
        end
        width = ax1_offset*0.1;
        xpatch = [x + width/2; x - width/2];
        ypatch = [y; flipdim(y,1)];
        patch(xpatch,ypatch,colors(i,:));
        
        % add text at midpoint of line
        ymid = (y(2)+y(1))/2;
        text(region_offset - width, ymid, regions{region1},...
            'HorizontalAlignment','Right');
        region1 = region2;
    end
end

if ~isempty(obj.time)
    obj.add_time_ticks('x');
    obj.add_vert_line(0);
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