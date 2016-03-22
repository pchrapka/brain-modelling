function match = regexp_first(str,expr,varargin)
%REGEXP_FIRST returns first regexp output
%   REGEXP_FIRST returns first regexp output

matches = regexp(str,expr,varargin{:});
if ~isempty(matches)
    match = matches{1};
else
    match = matches;
end

end