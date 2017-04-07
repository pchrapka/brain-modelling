function out = get_criteria(obj,varargin)

p = inputParser();
addParameter(p,'criteria','',@ischar);
addParameter(p,'orders',[],@(x) isempty(x) || isvector(x));
addParameter(p,'file_list',[],@(x) isempty(x) || isvector(x));
parse(p,varargin{:});

% copy vars
criteria = p.Results.criteria;
order_user = p.Results.orders;
file_list = p.Results.file_list;

% check file_list
if isempty(file_list)
    if length(obj.datafiles) > 1
        error('please specify file idx');
    else
        file_list = 1;
    end
end
% check file indices are within range
nfiles = length(file_list);
nfile_max = max(file_list);
if nfile_max > length(obj.datafiles)
    error('too many files specified (%d), available(%d)',nfile_max,length(obj.datafiles));
end


% extract data
count = 1;
legend_str = {};
dataf = {};
datab = {};
order_lists = {};
for i=1:nfiles
    file_idx = file_list(i);
    
    % load data
    obj.load('criteria',file_idx);
    
    % get dimensions
    [norders_data,nsamples] = size(obj.criteria.(criteria).f);
    
    % check orders
    if isempty(order_user)
        order_user = obj.criteria.(criteria).orders;
    end
    order_lists{i} = order_user;
    order_user_max = max(order_user);
    norders_user = length(order_user);
    
    if order_user_max > norders_data
        error('not enough orders in data (%d), requested (%d)',norders_data,order_user_max);
    end
    
    % use a file name label if there are many files
    if nfiles > 1
        filename = obj.datafile_labels{file_idx};
    else
        filename = '';
    end
    
    % extract criteria data
    % only use selected orders
    dataf{i} = obj.criteria.(criteria).f(order_user,:);
    datab{i} = obj.criteria.(criteria).b(order_user,:);
    
    % create legend string
    for k=1:norders_user
        order_idx = order_user(k);
        if isempty(filename)
            legend_str{count} = sprintf('order %d',order_idx);
        else
            legend_str{count} = sprintf('%s - order %d',filename,order_idx);
        end
        count = count + 1;
    end
end

out = [];
out.f = dataf;
out.b = datab;
out.legend_str = legend_str;
out.order_lists = order_lists;
out.file_list = file_list;

end