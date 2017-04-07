function plot_criteria_surface(obj,varargin)
%PLOT_CRITERIA_SURFACE plots filter order vs information criteria
%   PLOT_ESTERROR_VS_ORDER(...) plots filter order vs information criteria
%
%   Parameters
%   -----
%   criteria (string, default = 'aic')
%       criteria to plot
%   orders (vector)
%       list of orders to use in plot
%   file_idx (vector, default = 1)
%       indices of files whose data should be plotted

p = inputParser();
addParameter(p,'criteria','aic',@ischar);
addParameter(p,'orders',[],@isvector);
addParameter(p,'file_list',[],@isvector);
parse(p,varargin{:});

params = struct2namevalue(p.Results);
data_crit = obj.get_criteria(params{:});
nfiles = length(data_crit.f);
[norder,nsamples] = size(data_crit.f{1});

nplots = length(data_crit.order_lists{1});
nrows = ceil(sqrt(nplots));
ncols = nrows;

data_info = [];
for i=1:nfiles
    file_idx = data_crit.file_list(i);
    
    % parse gamma from file name
    pattern = 'gamma=([\d\.]+e[\d-+]+)';
    result = regexp(obj.datafiles{file_idx},pattern,'tokens');
    data_info(i).gamma = str2double(result{1}{1});
    
    % parse lambda from file name
    pattern = 'lambda=([\d\.]+)-';
    result = regexp(obj.datafiles{file_idx},pattern,'tokens');
    data_info(i).lambda = str2double(result{1}{1});
end

gamma_unique = unique([data_info.gamma]);
lambda_unique = unique([data_info.lambda]);

data_plot = nan(length(lambda_unique),length(gamma_unique),norder,nsamples);
for i=1:nfiles
    idx_gamma = find(gamma_unique == data_info(i).gamma,1,'first');
    idx_lambda = find(lambda_unique == data_info(i).lambda,1,'first');
    
    data_plot(idx_lambda,idx_gamma,:,:) = data_crit.f{i};
end

idx_end = ceil(nsamples*0.95);
npoints = ceil(nsamples/10);
idx_start = idx_end - npoints + 1;

figure('Position',[1 1 1000 800]);

k = 1;
for i=1:nrows
    for j=1:ncols
        if k <= norder
            subplot(nrows, ncols, k);
            
            % average data
            avg_data = squeeze(mean(data_plot(:,:,k,idx_start:idx_end),4));
            
            % find min value and corresponding lambda and gamma
            val_min = min(avg_data(:));
            [idx_lambda,idx_gamma] = find(avg_data == val_min,1,'first');
            
            % plot
            imagesc(avg_data);
            xlabel(sprintf('gamma - best %0.3g',gamma_unique(idx_gamma)));
            set_ticklabels(gamma_unique,'x');
            ylabel(sprintf('lambda - best %0.3g',lambda_unique(idx_lambda)));
            set_ticklabels(lambda_unique,'y');
            
            title(sprintf('order %d',k));
            
            k = k+1;
        end
    end
end
        

end

function set_ticklabels(data,axis)
nticks = length(data);
ticks = 1:nticks;
labels = cell(nticks,1);
for i=1:nticks
    labels{i} = sprintf('%0.3g',data(ticks(i)));
end
switch lower(axis)
    case 'x'
        set(gca, 'XTick', ticks);
        set(gca, 'XTickLabel', labels);
    case 'y'
        set(gca, 'YTick', ticks);
        set(gca, 'YTickLabel', labels);
    otherwise
        error('unknown axis %s',axis);
end

end