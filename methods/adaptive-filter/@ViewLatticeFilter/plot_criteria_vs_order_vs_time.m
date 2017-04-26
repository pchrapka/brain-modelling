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
%   file_list (vector, default = 1)
%       indices of files whose data should be plotted

p = inputParser();
addParameter(p,'criteria','ewaic',...
    @(x) any(validatestring(x,{'ewaic','ewsc','normerrortime',...
    'whitetime','minorigin_normerror_norm1coefs_time',...
    'minorigin_deterror_norm1coefs_time',...
    'norm1coefs_time','ewlogdet'})));
addParameter(p,'orders',[],@(x) true);
addParameter(p,'file_list',[],@(x) true);
parse(p,varargin{:});

params = struct2namevalue(p.Results);
data_crit = obj.get_criteria(params{:});

ndata = length(data_crit.legend_str);
nfiles = length(data_crit.f);
nsamples = size(data_crit.f{1},2);

% create figure name
[~,name,~] = fileparts(obj.datafiles{1});
name = strrep(name,'-',' ');
name = strrep(name,'_','-');
if nfiles > 1
    out = sprintf('%s-', obj.datafile_labels{:});
    name = [name '-' out(1:end-1)];
end

screen_size = get(0,'ScreenSize');
figure('Position',screen_size,'Name',name);
colors = get_colors(ndata,'jet');
markers = {'o','x','+','*','s','d','v','^','<','>','p','h'};

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
                data = data_crit.f;
                title_str{1} = sprintf('Forward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
            case 2
                data = data_crit.b;
                title_str{1} = sprintf('Backward IC - %s',upper(p.Results.criteria));
                ylabel_str = 'IC';
        end
        
        if j==1
            % plot IC vs samples
            h = zeros(ndata,1);
            count = 1;
            ymax = zeros(nfiles,1);
            ymin = zeros(nfiles,1);
            for file_idx=1:nfiles
                norders = size(data{file_idx},1);
                for k=1:norders
                    h(count) = plot(1:nsamples,data{file_idx}(k,:),...
                        obj.get_linetype(file_idx),...
                        'Color',colors(count,:));
                    count = count + 1;
                end
                
                idx = ceil(nsamples*0.05);
                ymax(file_idx) = max(max(data{file_idx}(:,idx:end)));
                ymin(file_idx) = min(data{file_idx}(:));
            end
            
            % labels
            xlabel('Sample');
            legend(h,data_crit.legend_str);
            
            % adjust axes
            xlim([1 nsamples]);
            ylim_new = [min(ymin) max(ymax)];
            offset = abs(diff(ylim_new))*0.1;
            ylim_new = [ylim_new(1)-offset ylim_new(2)+offset];
            ylim(ylim_new);
        end
        
        if j==2
            % plot converged avg IC vs order
            idx_end = ceil(nsamples*0.95);
            npoints = ceil(nsamples/10);
            idx_start = idx_end - npoints + 1;
            
            h = zeros(nfiles,1);
            for file_idx=1:nfiles
                avg_data = mean(data{file_idx}(:,idx_start:idx_end),2);
                h(file_idx) = plot(data_crit.order_lists{file_idx},...
                    avg_data,...
                    ['-' markers{file_idx}],'MarkerSize',10);
            end
            
            xlim_cur = xlim;
            xlim([xlim_cur(1)-0.5 xlim_cur(2)+0.5]);
            xlabel('Order');
            title_str{2} = sprintf('avg of samples %d-%d',idx_start,idx_end);
            if nfiles > 1
                legend(h,obj.datafile_labels);
            end
        end
        
        % add labels
        ylabel(ylabel_str);
        
        if ~isempty(title_str)
            title(title_str);
        end
        
    end
end

end