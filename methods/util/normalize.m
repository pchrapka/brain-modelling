function out = normalize(signal)
%NORMALIZE normalize vector by the std deviation
%   NORMALIZE(signal) normalize vector data by the std deviation
%   
%   Input
%   -----
%   signal (matrix)
%       signal matrix [channels samples]

out = signal./std(signal(:));
out(isnan(out)) = 0;

end