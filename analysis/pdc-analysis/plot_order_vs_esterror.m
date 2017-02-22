function plot_order_vs_esterror(file,varargin)
%PLOT_ORDER_VS_ESTERROR plots filter order vs estimation error
%   PLOT_ORDER_VS_ESTERROR(files,...) plots filter order vs estimation
%   error
%
%   Input
%   -----
%   files (cell array/string)
%       file names of data after lattice filtering

p = inputParser();
addRequired(p,'file',@ischar);
addParameter(p,'orders',@isvector);
% addParameter(p,'params',{},@iscell);
parse(p,file,varargin{:});

norders = length(p.Results.orders);

ferrors = zeros(norders,1);
berrors = zeros(norders,1);
orders = zeros(norders,1);

% load lattice filtered results
print_msg_filename(file,'loading');
data = loadfile(file);

% get final estimation error
dims = size(data.estimate.ferror);
norderp1 = dims(end);

if norders+1 > norderp1
    error('not enough orders in data (%d), requested (%d)',norderp1-1,norders);
end

for i=1:norders
    
    order = p.Results.orders(i);
    idx = order+1;
    
    switch length(dims)
        case 4
            ferror = data.estimate.ferror(:,:,:,idx);
            berror = data.estimate.berrord(:,:,:,idx);
        case 3
            ferror = data.estimate.ferror(:,:,idx);
            berror = data.estimate.berrord(:,:,idx);
        otherwise
            error('uh oh\n');
    end
    
    % compute the magnitude over all channels and trials
    orders(i) = order;
    ferrors(i) = norm(ferror(:));
    berrors(i) = norm(berror(:));
    
end

figure;
subplot(2,1,1);
plot(orders,ferrors);
xlabel('Model order');
ylabel('Forward Estimation Error');
[~,name,~] = fileparts(file);
title(strrep(name,'_',' '));

subplot(2,1,2);
plot(orders,berrors);
xlabel('Model order');
ylabel('Backward Estimation Error');

end

% function colors = get_colors(nmax,cmap_name)
% if nargin < 2
%     cmap_name = 'jet';
% end
% 
% % get colormap without changing the current one
% cmap_cur = colormap();
% cmap = colormap(cmap_name);
% colormap(cmap_cur);
% 
% ncolors = size(cmap,1);
% pct = 1:nmax/nmax;
% color_idx = ceil(ncolors*pct);
% colors = cmap(color_idx,:);
% end