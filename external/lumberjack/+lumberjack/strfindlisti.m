function out = strfindlisti(list, pattern)
%STRFINDLIST finds a pattern in a cell array of strings

out = ~cellfun('isempty',strfind(list,pattern));

end