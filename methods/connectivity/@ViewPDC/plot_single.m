function plot_single(obj,chj,chi)

p = inputParser();
addRequired(p,'chj',@isnumeric);
addRequired(p,'chi',@isnumeric);
parse(p,chj,chi);

obj.save_tag = [];
obj.load();
obj.check_info();

nfreqs = size(obj.pdc,4);
    
w = 0:nfreqs-1;
w = w/(2*nfreqs);

w_idx = (w >= obj.w(1)) & (w <= obj.w(2));
f = w(w_idx)*obj.fs;
freq_idx = 1:nfreqs;
freq_idx = freq_idx(w_idx);
nPlotPoints = length(freq_idx);

nticks = 6;
ytick = linspace(1, nPlotPoints, nticks);
yticklabel = cell(nticks,1);
for i=1:nticks
    yticklabel{i} = '';
end
yticklabel{1} = sprintf('%0.2f',obj.w(1)*obj.fs);
yticklabel{nticks} = sprintf('%0.2f',obj.w(2)*obj.fs);

data_plot = abs(squeeze(obj.pdc(:,chi,chj,freq_idx))');

clim = [0 1];
imagesc(data_plot,clim);
colorbar();

obj.labelity(chi);
obj.labelitx(chj);

set(gca,...
    'YTick', ytick, ...
    'YTickLabel', yticklabel,...
    'FontSize',10);

obj.save_tag = sprintf('-single-j%d-i%d',chj,chi);

end