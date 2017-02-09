function plot_pdc_dynamic_single(data,chj,chi,varargin)

p = inputParser();
fs_default = 1;
addRequired(p,'data',@isstruct);
addRequired(p,'chj',@isnumeric);
addRequired(p,'chi',@isnumeric);
addParameter(p,'w',[0 0.5],@(x) length(x) == 2 && isnumeric(2)); % not sure about this
addParameter(p,'fs',fs_default,@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
parse(p,data,chj,chi,varargin{:});

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
nPlotPoints = length(freq_idx);

hylabel = 0;
hxlabel = 0;

nticks = 6;
ytick = linspace(1, nPlotPoints, nticks);
yticklabel = cell(nticks,1);
for i=1:nticks
    yticklabel{i} = '';
end
yticklabel{1} = sprintf('%0.2f',p.Results.w(1)*fs);
yticklabel{nticks} = sprintf('%0.2f',p.Results.w(2)*fs);

data_plot = abs(squeeze(data.pdc(:,chi,chj,freq_idx))');

clim = [0 1];
imagesc(data_plot,clim);
colorbar();

hylabel(i) = labelity(i,p.Results.ChannelLabels);
hxlabel(chj) = labelitx(chj,p.Results.ChannelLabels);

set(gca,...
    'YTick', ytick, ...
    'YTickLabel', yticklabel,...
    'FontSize',10);

end

function [hxlabel] = labelitx(j,chLabels) % Labels x-axis plottings
if isempty(chLabels)
   hxlabel=xlabel(['j = ' int2str(j)]);
   set(hxlabel,'FontSize',12, ... %'FontWeight','bold', ...
      'FontName','Arial') % 'FontName','Arial'
else
   hxlabel = xlabel(chLabels{j});
   set(hxlabel,'FontSize',12) %'FontWeight','bold')
end
end

%% ========================================================================

function [hylabel] = labelity(i,chLabels) % Labels y-axis plottings
if isempty(chLabels)
   hylabel=ylabel(['i = ' int2str(i)],...
      'Rotation',90);
   set(hylabel,'FontSize',12, ... %'FontWeight','bold', ...
      'FontName','Arial')  % 'FontName','Arial', 'Times'
else
   hylabel=ylabel([chLabels{i}]);
   set(hylabel,'FontSize',12); %'FontWeight','bold','Color',[0 0 0])
end
end