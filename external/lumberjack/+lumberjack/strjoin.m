function [out] = strjoin(data)
% joins strings in cell array
out = sprintf('%s ', data{:});
end