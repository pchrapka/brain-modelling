function sources = bf_get_sources(data)
%BF_GET_SOURCES extracts source matrix from data struct
%   sources = BF_GET_SOURCES(data) extracts source matrix from data struct
%
%   Input
%   -----
%   data (struct)
%       source analysis data struct, currently only fieldtrip data is
%       supported
%
%   Output
%   ------
%   sources (matrix)
%       source matrix of size [sources time]

if isfield(data,'avg')
    if ~islogical(data.inside)
        error('inside index is not logical');
    end
    % get source data
    temp = data.avg.mom(data.inside);
    % convert to matrix [patches x time]
    sources = cell2mat(temp);
else
    error('unknown data struct');
end

end