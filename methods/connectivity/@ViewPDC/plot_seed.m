function created = plot_seed(obj,chseed,varargin)

p = inputParser();
addRequired(p,'chseed',@isnumeric);
addParameter(p,'stat','none',@(x) any(validatestring(x,{'none','mean','var'})));
addParameter(p,'operation','none',@(x) any(validatestring(x,{'none','sum','mean'})));
addParameter(p,'direction','outgoing',...
    @(x) any(validatestring(x,{'outgoing','incoming'})));
addParameter(p,'vertlines',[],@isvector);
addParameter(p,'threshold',0.05,@(x) x >= 0 && x <= 1);
addParameter(p,'threshold_mode','numeric',...
    @(x) any(validatestring(x,{'none','numeric','significance','significance_alpha'})));
addParameter(p,'tag','',@ischar);
addParameter(p,'get_save_tag',false,@islogical);
% addParameter(p,'save',false,@islogical);
% addParameter(p,'outdir','',@ischar);
parse(p,chseed,varargin{:});

obj.save_tag = [];
switch p.Results.stat
    case 'none'
        obj.load('pdc');
    case 'mean'
        obj.load('pdc_mean');
    case 'var'
        obj.load('pdc_var');
end
obj.check_info();
created = false;

label_seed = obj.info.label{p.Results.chseed};

%% set up save tag
tag_threshold = '';
switch p.Results.threshold_mode
    case 'none'
        tag_threshold = '';
    case 'numeric'
        tag_threshold = sprintf('-thresh%0.2f',p.Results.threshold);
    case 'significance'
        obj.load('pdc_sig');
        tag_threshold = '-threshsig';
    case 'significance_alpha'
        obj.load('pdc_sig');
        tag_threshold = '-threshsigalpha';
        error('fix this mode');
        % NOTE it doesn't make sense using the significance threshold as an
        % alpha layer
    otherwise
        % do nothing
        error('unknown threshold mode %s',p.Results.threshold_mode);
end

% set labels and save tag
switch p.Results.direction
    case 'outgoing'
        obj.save_tag = sprintf('-seed-out-j%d',p.Results.chseed);
    case 'incoming'        
        obj.save_tag = sprintf('-seed-in-i%d',p.Results.chseed);
end

tag_operation = sprintf('-op%s',p.Results.operation);
obj.save_tag = [obj.save_tag tag_operation];

if ~isempty(tag_threshold)
    % add threshold tag
    obj.save_tag = [obj.save_tag tag_threshold];
end

if ~isempty(p.Results.tag)
    % add user tag
    obj.save_tag = [obj.save_tag '-' p.Results.tag];
end

if p.Results.get_save_tag
    return;
end

%% plot
[nsamples,nchannels,~,nfreqs] = size(obj.pdc);
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
% nfreqs_selected = sum(w_idx);
% threshold = p.Results.threshold_pct*nfreqs_selected;
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);

nfreqs_sel = legnth(freq_idx);
data_plot = zeros(nsamples,nfreqs_sel,nchannels);
data_alpha = zeros(nsamples,nfreqs_sel,nchannels);
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
            if ~isempty(obj.pdc_sig)
                data_alpha_temp = squeeze(obj.pdc_sig(:,i,p.Results.chseed,freq_idx));
            end
        case 'incoming'
            data_temp = squeeze(obj.pdc(:,p.Results.chseed,i,freq_idx));
            if ~isempty(obj.pdc_sig)
                data_alpha_temp = squeeze(obj.pdc_sig(:,p.Results.chseed,i,freq_idx));
            end
    end
    
    % threshold data
    switch p.Results.threshold_mode
        case 'none'
            % do nothing
        case 'numeric'
            % zero out everything that doesn't meet the threshold
            data_temp(data_temp < p.Results.threshold) = 0;
        case 'significance'
            % zero out everything that doesn't meet the threshold
            data_temp(data_temp < data_alpha_temp) = 0;
        case 'significance_alpha'
            % handle later
        otherwise
            % do nothing
            error('unknown threshold mode %s',p.Results.threshold_mode);
    end
    
    % only add to plot if the whole sum is not 0
    data_sum = sum(data_temp(:));
    if data_sum > 0.01
        % sum over frequencies
        % TODO do sum elsewhere
        %data_plot(:,:,i) = sum(data_temp,2);
        data_plot(:,:,i) = data_temp;
        yticklabel{i} = obj.info.label{i};
        
        if isequal(p.Results.threshold_mode,'significance_alpha')
            % plot all data, add significance as alpha layer
            % TODO do sum elsewhere
            %data_alpha(i,:) = sum(data_alpha_temp,2);
            data_alpha(:,:,i) = data_alpha_temp;
        end
            
    end
end

idx_empty = cellfun(@isempty,yticklabel,'UniformOutput',true);

if sum(~idx_empty) == 0
    fprintf('%s: no %s connections for %s\n',mfilename,p.Results.direction,label_seed);
    created = false;
    return;
end

% sort by hemisphere, region, angle
idx_sort = obj.sort_channels();
idx_sort = idx_sort(:);

% sort the data
data_plot = data_plot(:,:,idx_sort);
yticklabel = yticklabel(idx_sort,:);
idx_empty = idx_empty(idx_sort,:);

% remove empty entries
data_plot(:,:,idx_empty) = [];
yticklabel(idx_empty,:) = [];

% set up figure
screen_size = get(0,'screensize');
labels_height = 200;
row_height = (screen_size(4)-labels_height)/length(yticklabel);
max_row_height = 100;
if row_height > max_row_height
    % limit row height
    fig_size = screen_size;
    fig_size(4) = ceil(max_row_height*length(yticklabel)) + labels_height;
    set(gcf,'Position',fig_size);
else
    % use full screen
    figure('Position', screen_size);
end

if ~isempty(obj.info.region)
    ax2 = gca;
    set(ax2,'Visible','off');
    ax1_pos = get(ax2,'Position');
    ax1_offset = 0.1;
    ax1_pos(1) = ax1_pos(1) + ax1_offset;
    ax1_pos(3) = ax1_pos(3) - ax1_offset;
    ax1 = axes('Position',ax1_pos);
else
    ax1 = gca;
end
axes(ax1);
set(ax1,'FontSize',12);

switch p.Results.operation
    case 'mean'
        ytick = 1:length(yticklabel);
        data_plot = squeeze(mean(data_plot,2));
    case 'sum'
        ytick = 1:length(yticklabel);
        data_plot = squeeze(sum(data_plot,2));
    case 'none'
        % do nothing
        ytick = 1:nfreqs_sel:(length(yticklabel)*nfreqs_sel);
        ytick = ytick + (nfreqs_sel - 1)/2;
        data_plot = reshape(data_plot,[nsamples,nfreqs_sel*nchannels]);
    otherwise
        error('unknown operation %s',p.Results.operation);
end

clim = [0 1];
im = imagesc(data_plot,clim);

% add white lines between channels
line_x = repmat([1 nsamples],[length(yticklabel) 1]);
line_y = repmat(ytick(:), [1 2]);
line(line_x,line_y,'Color','black','LineWidth',1);

% set colormap
cmap = colormap(hot);
cmap = flipdim(cmap,1);
colormap(cmap);
colorbar();

switch p.Results.threshold_mode
    case 'significance_alpha'
        if verLessThan('matlab','7.15')
            alpha(data_alpha)
        else
            set(im,'AlphaData',data_alpha);
        end
end
created = true;

% add left axis with channel labels
set(gca,...
    'YTick', ytick, ...
    'YTickLabel', yticklabel,...
    'FontSize',12);

% add time info
if ~isempty(obj.time)
    obj.add_time_ticks('x');
    
    if ~isempty(p.Results.vertlines)
        % add vertical lines
        vertlines = p.Results.vertlines;
        for i=1:length(vertlines)
            obj.add_vert_line(vertlines(i));
        end
    end
end

% set labels
switch p.Results.direction
    case 'outgoing'
        str_xlabel = 'from';
        xlabel_string{1} = sprintf('%s %s',str_xlabel,label_seed);
        if ~isempty(obj.info.region)
            xlabel_string{2} = obj.info.region{p.Results.chseed};
        end 
        ylabel('to');
        xlabel(xlabel_string);
    case 'incoming'
        str_xlabel = 'to';
        xlabel_string{1} = sprintf('%s %s',str_xlabel,label_seed);
        if ~isempty(obj.info.region)
            xlabel_string{2} = obj.info.region{p.Results.chseed};
        end
        ylabel('from');
        xlabel(xlabel_string);
end

% add region bar on left side
if ~isempty(obj.info.region)
    set(ax2,'FontSize',12);
    set(ax2,'YLim',get(ax1,'YLim'),'YDir',get(ax1,'YDir'));
    axes(ax2);
    xlim([0 1]);
    
    % set up colors
    colors = obj.get_region_cmap('jet');
    
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
    if length(ytick) > 1
        ytick_inc = ytick(2)-ytick(1);
    else
        yylim = ylim;
        ytick_inc = yylim(2) - yylim(1);
    end
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
        if y(2) <= y(1)
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
            'HorizontalAlignment','Right','FontSize',12);
        region1 = region2;
    end
end

end