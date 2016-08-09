function datenum = get_timestamp(file_name)
D = dir(file_name);
if length(D) > 1
    error('found more than one file');
end

datenum = D(1).datenum;
end