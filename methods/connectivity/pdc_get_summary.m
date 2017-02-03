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
fs_default = 1;
addRequired(p,'data',@isstruct);
addParameter(p,'w_max',0.5,@(x) isnumeric(x) && x <= 0.5); % not sure about this
addParameter(p,'fs',fs_default,@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
parse(p,data,varargin{:});

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