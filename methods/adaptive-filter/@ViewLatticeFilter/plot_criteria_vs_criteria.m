function plot_criteria_vs_criteria(obj,varargin)
% plots one criteria vs another criteria

%   Parameters
%   ----------
%   criteria1 (string)
%       first criteria to plot
%   criteria2 (string)
%       second criteria to plot
%   order (integer)
%       order to use for plot
%   file_list (vector, default = [])
%       indices of files whose data should be plotted

p = inputParser();
addParameter(p,'criteria1','normerrortime',@ischar);
addParameter(p,'criteria2','norm1coefs_time',@ischar);
addParameter(p,'orders',[],@(x) (length(x) == 1) && isnumeric(x));
addParameter(p,'file_list',[],@(x) true);
addParameter(p,'criteria_samples',[],@(x) (length(x) == 2) && isnumeric(x));
parse(p,varargin{:});

data_crit1 = obj.get_criteria(...
    'criteria',p.Results.criteria1,...
    'orders',p.Results.orders,...
    'file_list',p.Results.file_list);

data_crit2 = obj.get_criteria(...
    'criteria',p.Results.criteria2,...
    'orders',p.Results.orders,...
    'file_list',p.Results.file_list);

nfiles = length(data_crit1.f);
nsamples = size(data_crit1.f{1},2);

crit_idx = p.Results.criteria_samples;
if isempty(crit_idx)
    crit_idx = [1 nsamples];
end

screen_size = get(0,'ScreenSize');
figure('Position',screen_size);%,'Name',name);
colors = get_colors(nfiles,'jet');
markers = {'o','x','+','*','s','d','v','^','<','>','p','h'};

nrows = 1;
ncols = 2;
for i=1:2
    subplot(nrows,ncols,i);
    
    switch i
        case 1
            data1 = data_crit1.f;
            data2 = data_crit2.f;
            title_str{1} = 'Forward IC';
        case 2
            data1 = data_crit1.b;
            data2 = data_crit2.b;
            title_str{1} = 'Backward IC';
    end
    
    %avg_data1 = zeros(nfiles,1);
    %avg_data2 = zeros(nfiles,1);
    h = [];
    for file_idx=1:nfiles
        avg_data1 = mean(data1{file_idx}(crit_idx(1):crit_idx(2)));
        avg_data2 = mean(data2{file_idx}(crit_idx(1):crit_idx(2)));
        h(file_idx) = scatter(avg_data1, avg_data2, 60, colors(file_idx,:), markers{file_idx});
        hold on;
        axis square;
    end
    
    title(title_str);
    xlabel(strrep(p.Results.criteria1,'_',' '));
    ylabel(strrep(p.Results.criteria2,'_',' '));
    legend(h,data_crit1.legend_str);
end

end
