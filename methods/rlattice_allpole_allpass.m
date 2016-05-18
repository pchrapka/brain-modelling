function Y = rlattice_allpole_allpass(Kf,Kb,X)
%RLATTICE_ALLPOLE_ALLPASS synthesizes white noise to AR process
%   Y = RLATTICE_ALLPOLE_ALLPASS(Kf, Kb, X) reverse all-pole all-pass
%   lattice filter. Generates an AR process from white noise with the
%   specified reflection coefficients
%
%   See Haykin, Adaptive Filter Theory (4th Ed.), 2002, Section 3.9 p.180
%
%   Input
%   -----
%   Kf (matrix)
%       forward reflection coefficients [order channels channels]
%   Kb (matrix)
%       backward reflection coefficients [order channels channels]
%   X (matrix)
%       white noise [channels samples]
%
%   Output
%   ------
%   Y (matrix)
%       AR process [channels samples]

[nchannels, nsamples] = size(X);
norder = size(Kf,1);

% init mem
zeroMat = zeros(nchannels, norder+1);
ferror = zeroMat;
berror = zeroMat;
berrord = zeroMat;
Y = zeros(nchannels, nsamples);

for j=1:nsamples
    % input
    ferror(:,norder+1) = X(:,j);
    
    % calculate forward and backward error at each stage
    for p=norder+1:-1:2
        ferror(:,p-1) = ferror(:,p) + squeeze(Kb(p-1,:,:))*berrord(:,p-1);
        berror(:,p) = berrord(:,p-1) - squeeze(Kf(p-1,:,:))'*ferror(:,p-1);
        % Structure is from Haykin, p.179, sign convention is from
        % Lewis1990
    end
    berror(:,1) = ferror(:,1);
%     display(berror)
%     display(ferror)
    
    % delay backwards error
    berrord = berror;
    
    % save 0th order forward error as output
    Y(:,j) = ferror(:,1);
end




end