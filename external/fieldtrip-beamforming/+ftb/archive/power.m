function [ power ] = power(data)
%power Calculates the power of the data
%   power(data) returns the power of the data
%
%   Input
%   data  (channels x samples)

% Get the dimensions
n_channels = size(data,1);
n_samples = size(data,2);

% Instead of tr( 1/n_samples XX^T )
% 1/n_samples ( sum(channel(i)^T channel(i)))

sum = 0;
for i=1:n_channels
   sum = sum + data(i,:)*data(i,:)';
end
power = sum/n_samples;

end