function out = normalizev(signal)
%NORMALIZEV normalize vector data by the std deviation of each channel
%   NORMALIZEV(signal) normalize vector data by the std deviation of each
%   channel
%   
%   Input
%   -----
%   signal (matrix)
%       signal matrix [channels samples]

nsamples = size(signal,2);
out = signal./repmat(std(signal,0,2),1,nsamples);
out(isnan(out)) = 0;

end