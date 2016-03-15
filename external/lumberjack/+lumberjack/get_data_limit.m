function [data_min, data_max] = get_data_limit(data)
%GET_DATA_LIMIT returns the min and max of a cell array of data
%
%   data
%       cell array matrices

n_data = length(data);

data_max = 0;
data_min = 0;
for j=1:n_data
    data_max_new = max(max(data{j}));
    data_min_new = min(min(data{j}));
    if data_max_new > data_max
        data_max = data_max_new;
    end
    if data_min_new < data_min
        data_min = data_min_new;
    end
end

end