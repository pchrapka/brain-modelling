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
%       source matrix of size [sources time] or [source time trials]

if isfield(data,'avg')
    if ~islogical(data.inside)
        error('inside index is not logical');
    end
    % get source data
    temp = data.avg.mom(data.inside);
    % convert to matrix [patches x time]
    sources = cell2mat(temp);
elseif isfield(data,'trial')
    if ~islogical(data.inside)
        error('inside index is not logical');
    end
    ntrials = length(data.trial);
    nsources = sum(data.inside);
    temp = data.trial(1).mom(data.inside);
    ntime = length(temp{1});
    sources = zeros(nsources, ntime, ntrials);
    
    % copy vars for parfor
    data_trial = data.trial;
    data_inside = data.inside;
    parfor i=1:ntrials
        % get source data
        temp = data_trial(i).mom(data_inside);
        % convert to matrix [patches x time]
        sources(:,:,i) = cell2mat(temp);
    end
else
    error('unknown data struct');
end

end