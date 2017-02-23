function plot_esterror_vs_order_vs_time(obj,varargin)
%PLOT_ESTERROR_VS_ORDER_VS_TIME plots filter order vs estim. error vs time
%   PLOT_ESTERROR_VS_ORDER_VS_TIME(...) plots filter order vs estimation
%   error vs time
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
nsamples = dims(1);

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
ferrors = zeros(nsamples,norders);
berrors = zeros(nsamples,norders);

legend_str = cell(norders,1);
for i=1:norders
    for j=1:nsamples
        
        order = order_list(i);
        idx = order+1;
        
        switch length(dims)
            case 4
                ferror = obj.data.estimate.ferror(j,:,:,idx);
                berror = obj.data.estimate.berrord(j,:,:,idx);
            case 3
                ferror = obj.data.estimate.ferror(j,:,idx);
                berror = obj.data.estimate.berrord(j,:,idx);
            otherwise
                error('uh oh\n');
        end
        ferror = squeeze(ferror);
        berror = squeeze(berror);
        
        % compute the magnitude over all channels and trials
        ferrors(j,i) = norm(ferror(:));
        berrors(j,i) = norm(berror(:));
    end
    
    legend_str{i} = sprintf('%d',order);
end

[~,name,~] = fileparts(obj.file);
name = strrep(name,'-',' ');
name = strrep(name,'_','-');
screen_size = get(0,'ScreenSize');
figure('Position',screen_size,'Name',name);
colors = get_colors(norders,'jet');

nrows = 2;
ncols = 2;
plot_idx = 0;
for i=1:nrows
    for j=1:ncols
        plot_idx = plot_idx + 1;
        subplot(nrows,ncols,plot_idx);
        hold on;
        
        title_str = {};
        switch i
            case 1
                data = ferrors;
                title_str{1} = 'Forward Estimation Error';
                ylabel_str = 'Error';
            case 2
                data = berrors;
                title_str{1} = 'Backward Estimation Error';
                ylabel_str = 'Error';
        end
        
        if j==2
            % plot moving average in second row
            npoints = ceil(nsamples/20);
            buffer = repmat(data(1,:),npoints,1);
            %buffer = zeros(npoints,norders);
            dataout = zeros(size(data));
            for s=1:nsamples
                buffer = circshift(buffer,1);
                buffer(1,:) = data(s,:);
                
                dataout(s,:) = mean(buffer,1);
            end
            data = dataout;
            title_str{2} = sprintf('%d-point moving average',npoints);
        end
        
        h = zeros(norders,1);
        for k=1:norders
            h(k) = plot(1:nsamples,data(:,k),'-o','Color',colors(k,:),'MarkerSize',2);
            %h(i) = scatter(1:nsamples,ferrors(:,k),2,colors(k,:),'filled');
        end
        
        % add labels
        xlabel('Sample');
        ylabel(ylabel_str);
        
        % add title and legned
        if i==1 && j==1
            legend(h,legend_str);
        end
        
        if ~isempty(title_str)
            title(title_str);
        end
        
    end
end

end
