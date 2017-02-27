function out = normalize(signal)
%NORMALIZE normalize vector by the std dev of all channels in aggregate
%   NORMALIZE(signal) normalize vector by the std dev of all channels in
%   aggregate
%   
%   Input
%   -----
%   signal (matrix)
%       signal matrix [channels samples]

out = signal./std(signal(:));
out(isnan(out)) = 0;

end