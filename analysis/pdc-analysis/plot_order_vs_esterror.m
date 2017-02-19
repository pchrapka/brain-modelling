function plot_order_vs_esterror(files,varargin)
%PLOT_ORDER_VS_ESTERROR plots filter order vs estimation error
%   PLOT_ORDER_VS_ESTERROR(files,...) plots filter order vs estimation
%   error
%
%   Input
%   -----
%   files (cell array/string)
%       file names of data after lattice filtering

p = inputParser();
addRequired(p,'files',@iscell);
% addParameter(p,'params',{},@iscell);
parse(p,files,varargin{:});

ndata = length(files);

ferrors = zeros(ndata,1);
berrors = zeros(ndata,1);
orders = zeros(ndata,1);

for i=1:ndata
    
    % load lattice filtered results
    print_msg_filename(files{i},'loading');
    data = loadfile(files{i});
    
    % get final estimation error
    dims = size(data.estimate.ferror);
    norderp1 = dims(end);
    
    switch length(dims)
        case 3
            ferror = data.estimate.ferror(:,:,norderp1);
            berror = data.estimate.berrord(:,:,norderp1);
        case 2
            ferror = data.estimate.ferror(:,norderp1);
            berror = data.estimate.berrord(:,norderp1);
        otherwise
            error('uh oh\n');
    end
    
    % compute the magnitude over all channels and trials
    orders(i) = norderp1 - 1;
    ferrors(i) = norm(ferror(:));
    berrors(i) = norm(berror(:));
    
end

figure;
subplot(2,1,1);
plot(orders,ferrors);
xlabel('Model order');
ylabel('Forward Estimation Error');
[~,name,~] = fileparts(files{1});
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