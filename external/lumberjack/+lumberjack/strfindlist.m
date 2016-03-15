function match = strfindlist(list, pattern)

result = lumberjack.strfindlisti(list, pattern);
if sum(result) == 0
    match = '';
else
    match = list{result};
end

end