function [data_metric, jchannel_idx, ichannel_idx] = pdc_get_summary(data)
%PDC_GET_SUMMARY summarizes magnitude of PDC data for each channel pair
%   PDC_GET_SUMMARY(data) summarizes magnitude of PDC data for each channel
%   pair
%
%
%   Output
%   ------
%   data_metric (vector)
%       sum of PDC for channel pair
%   jchannel_idx (vector)
%       corresponding jth-channel index, also row index
%   ichannel_idx (vector)
%       corresponding ith-channel index, also column index

p = inputParser();
addRequired(p,'data',@isstruct);
parse(p,data);

dims = size(data.pdc);
ndims = length(dims);
if ndims == 4
    % dynamic pdc
    [nsamples,nchannels,~,nfreqs]=size(data.pdc); 
else
    error('requires dynamic pdc data');
end

ichannel_idx = zeros(nchannels, nchannels);
jchannel_idx = zeros(nchannels, nchannels);
data_metric = zeros(nchannels, nchannels);
for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            
            data_temp = abs(squeeze(data.pdc(:,i,j,:))');
            
            ichannel_idx(j,i) = i;
            jchannel_idx(j,i) = j;
            data_metric(j,i) = sum(data_temp(:));
        end
        
    end
end

data_metric = data_metric(:);
ichannel_idx = ichannel_idx(:);
jchannel_idx = jchannel_idx(:);

end