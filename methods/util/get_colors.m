function colors = get_colors(nmax,cmap_name)
if nargin < 2
    cmap_name = 'jet';
end

% get colormap without changing the current one
cmap_cur = colormap();
cmap = colormap(cmap_name);
colormap(cmap_cur);

ncolors = size(cmap,1);
pct = (1:nmax)/nmax;
color_idx = ceil(ncolors*pct);
colors = cmap(color_idx,:);
end