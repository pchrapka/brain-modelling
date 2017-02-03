function plot_pdc_dynamic_single(data,j,i,varargin)

p = inputParser();
fs_default = 1;
addRequired(p,'data',@isstruct);
addRequired(p,'j',@isnumeric);
addRequired(p,'i',@isnumeric);
addParameter(p,'w_max',0.5,@(x) isnumeric(x) && x <= 0.5); % not sure about this
addParameter(p,'fs',fs_default,@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
parse(p,data,j,i,varargin{:});

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
w_min = w(1);

hylabel = 0;
hxlabel = 0;
ytick = linspace(1, nPlotPoints, 6);

data_plot = abs(squeeze(data.pdc(:,i,j,1:nPlotPoints))');

clim = [0 1];
imagesc(data_plot,clim);
colorbar();

hylabel(i) = labelity(i,p.Results.ChannelLabels);
hxlabel(j) = labelitx(j,p.Results.ChannelLabels);

set(h,...
    'YTick', ytick, ...
    'YTickLabel',[' 0';'  ';'  ';'  ';'  ';'.5'],...
    'FontSize',10);

end

function [hxlabel] = labelitx(j,chLabels) % Labels x-axis plottings
if isempty(chLabels)
   hxlabel=xlabel(['j = ' int2str(j)]);
   set(hxlabel,'FontSize',12, ... %'FontWeight','bold', ...
      'FontName','Arial') % 'FontName','Arial'
else
   hxlabel=xlabel([chLabels{j}]);
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