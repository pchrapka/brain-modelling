function Kmse = mse_coefs(Kest, Ktrue, mode)
%MSE_COEFS calculates MSE between true and estimated coefficients
%   MSE_COEFS(KEST, KTRUE, MODE) calculates MSE between true and estimated
%   coefficients
%
%   Input
%   -----
%   Kest (matrix)
%       estimated coefficients, [nsamples order channels channels]
%
%   Ktrue (matrix)
%       true coefficients, can be specified as [nsamples order channels
%       channels] or [order channels channels]
%   mode (string)
%       MSE calculation mode
%       'channels'
%           calculates MSE by taking the mean over channel pairs
%       'time'
%           calculates MSE by taking the mean over samples
%
%   Output
%   ------
%   Kmse (matrix)
%       MSE of coefficients, size depends on mode

% check lengths of coefficient matrices
Kest_size = size(Kest);
Ktrue_size = size(Ktrue);
if ~isequal(length(Kest_size),length(Ktrue_size))
    % check dimension sizes
    if isequal(Ktrue_size,Kest_size(2:end))
        % repeat true over nsamples
        nsamples = size(Kest,1);
        Ktrue = repmat(shiftdim(Ktrue,-1),nsamples,1,1,1);
    else
        error('matrix mismatch');
    end
else
    % equal dimensions
    % check dimension sizes
    if ~isequal(Kest_size, Ktrue_size)
        error('matrix mismatch');
    end
end

% get dimension sizes
[nsamples,order,nchannels,nchannels2] = size(Kest);
if ~isequal(nchannels, nchannels2)
    error('channels are not equal');
end

% calculate mse based on mode
switch mode
    case 'channels'
        % reshape to get all channels as one dimension
        Kest = reshape(Kest, [nsamples order nchannels^2]);
        Ktrue = reshape(Ktrue, [nsamples order nchannels^2]);
        
        Kmse = squeeze(mse(Kest, Ktrue, 3));
    case 'time'
        Kmse = squeeze(mse(Kest, Ktrue, 1));
    otherwise
        error('unknown mode %s', mode);
end

end