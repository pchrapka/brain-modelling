function plot_criteria_vs_order_vs_time(obj,varargin)
%PLOT_ESTERROR_VS_ORDER_VS_TIME plots filter order vs estim. error vs time
%   PLOT_ESTERROR_VS_ORDER_VS_TIME(...) plots filter order vs estimation
%   error vs time
%
%   Parameters
%   -----
%   criteria (string, default = 'ewaic')
%       criteria to plot
%   orders (vector)
%       list of orders to use in plot
%   file_idx (vector, default = 1)
%       indices of files whose data should be plotted

p = inputParser();
addParameter(p,'criteria','ewaic',...
    @(x) any(validatestring(x,{'ewaic','ewsc','normtime'})));
addParameter(p,'orders',[],@isvector);
addParameter(p,'file_idx',[],@isvector);
parse(p,varargin{:});

% check file_idx
if length(obj.datafiles) > 1 && isempty(p.Results.file_idx)
    error('please specify file idx');
elseif length(obj.datafiles) == 1
    file_idx = 1;
else
    file_idx = p.Results.file_idx;
end

if length(file_idx) > 1
    error('modify function to reflect multiple files');
end

% load data
obj.load('criteria',file_idx);
criteria = p.Results.criteria;

% get dimensions
[norders_data,nsamples] = size(obj.criteria.(criteria).f);
order_list = obj.criteria.(criteria).orders;

% check orders
if isempty(p.Results.orders)
    order_user = order_list;
else
    order_user = p.Results.orders;
end
order_user_max = max(order_user);
norders_user = length(order_user);

if order_user_max > norders_data
    error('not enough orders in data (%d), requested (%d)',norders_data,order_user_max);
end

if length(file_idx) == 1
    [~,name,~] = fileparts(obj.datafiles{file_idx});
    name = strrep(name,'-',' ');
    name = strrep(name,'_','-');
else
    name = 'TODO fix me';
end

screen_size = get(0,'ScreenSize');
figure('Position',screen_size,'Name',name);
colors = get_colors(norders_user,'jet');

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
                data = obj.criteria.(criteria).f;
                title_str{1} = sprintf('Forward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
            case 2
                data = obj.criteria.(criteria).b;
                title_str{1} = sprintf('Backward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
        end
        
        if j==1
            % plot IC vs samples
            h = zeros(norders_data,1);
            legend_str = cell(norders_data,1);
            for k=1:norders_user
                order_idx = orders_user(k);
                h(k) = plot(1:nsamples,data(order_idx,:),'-o','Color',colors(k,:),'MarkerSize',2);
                legend_str{k} = sprintf('order %d',order_idx);
            end
            
            xlabel('Sample');
        end
        
        if j==2
            % plot last IC vs order
            plot(orders_user,data(orders_user,nsamples),'-o');
            
            xlabel('Order');
            title_str{2} = sprintf('sample %d',nsamples);
        end
        
        % add labels
        ylabel(ylabel_str);
        
        % add legend
        if i==1 && j==1
            legend(h,legend_str);
        end
        
        if ~isempty(title_str)
            title(title_str);
        end
        
    end
end

end