function [X,X_norm,noise] = gen_stationary_ar(A, nsamples)
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
%   X (matrix)
%       stationary AR process, [channels nsamples]
%   X_norm (matrix)
%       normalized stationary AR process, with a variance of 1,
%       [channels nsamples]
%   N (matrix)
%       noise

nchannels = size(A,2);
if nchannels == 1
    noise = randn(1,nsamples);
    
    X = filter(1, A, noise);
    
    % normalize X to unit variance
    X_norm = X/std(X);
    disp(var(X/std(X))) % should be 1
else
    order = size(A,1)-1;
    % NOTE I'm assuming A(1,:,:) are ones
    
    % allocate output
    % add in a buffer of size order
    X = zeros(nchannels, nsamples+order);
    noise = randn(nchannels, nsamples+order);
    
    tstart = 1 + order;
    tend = nsamples + order;
    for t=tstart:tend
        for k=1:order
            % skip the first A, we're assuming they're all ones
            X(:,t) = X(:,t) + squeeze(-1*A(k+1,:,:))*X(:,t-k);
        end
        X(:,t) = X(:,t) + noise(:,t);
    end
    
    % remove extra entries
    X(:,1:order) = [];
    noise(:,end-order+1:end) = [];
    
    % normalize variance of each channel to unit variance
    X_norm = normalizev(X);
end

end