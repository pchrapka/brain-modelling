function [x,x_norm,noise] = gen_stationary_ar(A, nsamples)
%GEN_STATIONARY_AR generates a stationary AR process
%   GEN_STATIONARY_AR(A, NSAMPLES) generates a stationary AR process
%
%   Input
%   -----
%   A (matrix)
%       AR coefficients, [order+1 channels channels]
%   nsamples (integer)
%       number of samples to generate
%
%   Output
%   ------
%   x (matrix)
%       stationary AR process, [channels nsamples]
%   x_norm (matrix)
%       normalized stationary AR process, with a variance of 1,
%       [channels nsamples]

nchannels = size(A,2);
if nchannels == 1
    noise = randn(1,nsamples);
    
    x = filter(1, A, noise);
    
    % normalize x to unit variance
    x_norm = x/std(x);
    disp(var(x/std(x))) % should be 1
else
    order = size(A,1)-1;
    % NOTE I'm assuming A(1,:,:) are ones
    
    % allocate output
    % add in a buffer of size order
    x = zeros(nchannels, nsamples+order);
    noise = randn(nchannels, nsamples+order);
    
    tstart = 1 + order;
    tend = nsamples + order;
    for t=tstart:tend
        for k=1:order
            % skip the first A, we're assuming they're all ones
            x(:,t) = x(:,t) + squeeze(-1*A(k+1,:,:))*x(:,t-k);
        end
        x(:,t) = x(:,t) + noise(:,t);
    end
    
    % remove extra entries
    x(:,1:order) = [];
    noise(:,end-order+1:end) = [];
    
    % normalize variance of each channel to unit variance
    x_norm = x./repmat(std(x,0,2),1,nsamples);
end

end