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

% TODO how to specify file_idx
if length(obj.datafiles) > 1 && isempty(p.Results.file_idx)
    error('please specify file idx');
else
    file_idx = 1;
end

if length(file_idx) > 1
    error('modify function to reflect multiple files');
end

% load data
obj.load('criteria',file_idx);
criteria = p.Results.criteria;

% get dimensions
[norders,nsamples] = size(obj.criteria.(criteria).f);
order_list = obj.criteria.(criteria).orders;
order_max = max(order_list);

if order_max > norders
    error('not enough orders in data (%d), requested (%d)',norders,order_max);
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
            h = zeros(norders,1);
            legend_str = cell(norders,1);
            for k=1:norders
                h(k) = plot(1:nsamples,data(k,:),'-o','Color',colors(k,:),'MarkerSize',2);
                legend_str{k} = sprintf('order %d',order_list(k));
            end
            
            xlabel('Sample');
        end
        
        if j==2
            % plot last IC vs order
            plot(order_list,data(:,nsamples),'-o');
            
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