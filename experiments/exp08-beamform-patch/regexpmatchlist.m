function matches = regexpmatchlist(list,expr)

cell_matches = cellfun(@(x) regexp(x, expr, 'match'), list, 'UniformOutput',false);
matches = [cell_matches{:}];

end