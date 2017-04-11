function plot_moving_covariance(data, varargin)
% 
%   mode = channels
%       data size is [channels, samples, trials]
%   mode = covariance 
%       data size is [samples, channels, channels]

p = inputParser();
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'mode','channels',@(x) any(validatestring(x,{'channels','covariance'})));
addParameter(p,'normalize',false,@islogical);
parse(p,varargin{:});

dims = size(data);
switch p.Results.mode
    case 'channels'
        % [channels, samples, trials]
        if dims(2) < dims(1) && dims(2) < dims(3)
            error('expected more samples');
        end
        
        [nchannels, nsamples, ntrials] = size(data);
        if p.Results.normalize
            data_norm = zeros(size(data));
            for i=1:ntrials
                var_ch = var(data(:,:,i),0,2);
                data_norm(:,:,i) = data(:,:,i)./repmat(var_ch,[1,nsamples]);
            end
        else
            data_norm = data;
        end
        R = zeros(nsamples, nchannels, nchannels);
        for i=2:nsamples
            data_sample = squeeze(data_norm(:,i,:));
            weight = (1-p.Results.lambda)/(1-p.Results.lambda^i);
            R(i,:,:) = weight*(data_sample*data_sample')/ntrials;
        end
            
    case 'covariance'
        % [iterations, channels, channels]
        if length(dims) ~= 3
            error('bad data size for covariance matrices');
        end
        if dims(2) ~= dims(3)
            error('bad data size for covariance matrices');
        end
        
        [nsamples, nchannels, ~] = size(data);
        R = data;
    otherwise
        error('unknown mode');
end

R_weighted = zeros(nsamples, nchannels, nchannels);
for i=1:nsamples
    weight = (1-p.Results.lambda)/(1-p.Results.lambda^i);
    R_weighted(i,:,:) = weight*R(i,:,:);
end

corr_ch = zeros(nsamples, nchannels);
for i=1:nsamples
    Rtemp = abs(squeeze(R_weighted(i,:,:)));
    corr_ch(i,:) = diag(Rtemp)./sum(Rtemp,2);
end

nplots = nchannels;
ncols = 2;
nrows = ceil(nplots/ncols);

count = 1;
for i=1:nrows
    for j=1:ncols
        if count <= nchannels
            subplot(nrows,ncols,count);
            plot(1:nsamples, corr_ch(:,count));
            ylim([0 1]);
            xlim([1 nsamples]);
            title(sprintf('channel %d',count));
            count = count + 1;
        end
    end
end


end

