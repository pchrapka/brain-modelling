function plot_esterror_vs_order(obj,varargin)
%PLOT_ESTERROR_VS_ORDER plots filter order vs estimation error
%   PLOT_ESTERROR_VS_ORDER(...) plots filter order vs estimation error
%
%   Parameters
%   -----
%   orders (vector)
%       list of orders to use in plot

p = inputParser();
addParameter(p,'orders',[],@isvector);
% addParameter(p,'params',{},@iscell);
parse(p,varargin{:});

obj.load();

% get dimensions
dims = size(obj.data.estimate.ferror);
norderp1 = dims(end);

% set default orders
if isempty(p.Results.orders)
    order_list = 1:norderp1-1;
else
    order_list = p.Results.orders;
end
norders = length(order_list);
order_max = max(order_list);

if order_max > norderp1-1
    error('not enough orders in data (%d), requested (%d)',norderp1-1,order_max);
end

% allocate mem
ferrors = zeros(norders,1);
berrors = zeros(norders,1);

for i=1:norders
    
    order = order_list(i);
    idx = order+1;
    
    switch length(dims)
        case 4
            ferror = obj.data.estimate.ferror(:,:,:,idx);
            berror = obj.data.estimate.berrord(:,:,:,idx);
        case 3
            ferror = obj.data.estimate.ferror(:,:,idx);
            berror = obj.data.estimate.berrord(:,:,idx);
        otherwise
            error('uh oh\n');
    end
    
    % compute the magnitude over all channels and trials
    ferrors(i) = norm(ferror(:));
    berrors(i) = norm(berror(:));
    
end

figure;
subplot(2,1,1);
plot(order_list,ferrors,'-o');
xlabel('Model order');
ylabel('Forward Estimation Error');
[~,name,~] = fileparts(obj.file);
name = strrep(name,'-',' ');
name = strrep(name,'_','-');
title(name);

subplot(2,1,2);
plot(order_list,berrors,'-o');
xlabel('Model order');
ylabel('Backward Estimation Error');

end