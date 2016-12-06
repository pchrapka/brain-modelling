function out = normalizev(signal)
%NORMALIZEV normalize vector data by the std deviation
%   NORMALIZEV(signal) normalize vector data by the std deviation
%   
%   Input
%   -----
%   signal (matrix)
%       signal matrix [channels samples]

nsamples = size(signal,2);
out = signal./repmat(std(signal,0,2),1,nsamples);

end