function [Kfmse, Kbmse] = mse_reflection_coefs(K_est, Kf, Kb, varargin)
%MSE_REFLECTION_COEFS calculates MSE between true and estimated reflection
%coefs
%   MSE_REFLECTION_COEFS(K_EST, Kf, Kb, [repeat]) calculates MSE
%   between true and estimated reflection coefs
%
%   Input
%   -----
%   K_est (struct)
%       estimated reflection coefficients, specified as a struct with the
%       following fields
%
%       K_est.Kf
%           forward reflection coefficients, depending on algorithm 
%           [nsamples order channels channels]
%       K_est.Kb
%           backward reflection coefficients, depending on algorithm
%           [nsamples order channels channels]
%       K_est.scale
%           scaling for reflection coefficients, for example sometimes they
%           may be inverted
%
%   Kf (matrix)
%       true forward reflection coefficients [order channels channels]
%       if repeat = 'false' then Kf has the size [nsamples order
%       channels channels]
%   Kb (matrix)
%       true backward reflection coefficients [order channels channels]
%       if repeat = 'false' then Kb has the size [nsamples order
%       channels channels]
%   repeat (boolean, default = true)
%       flag that indivates if Kf and Kb need to be repeated to match the
%       dimensions of K_est.Kf and K_est.Kb
%
%
%   Output
%   ------
%   Kfmse (matrix)
%       MSE of forward reflection coefficients [order channels channels]
%   Kbmse (matrix)
%       MSE of backward reflection coefficients [order channels channels]

if nargin > 3
    repeat = varargin{1};
else
    repeat = true;
end

if repeat
    % Expand reflection coefficients
    nsamples = size(K_est.Kb,1);
    Kf_target = repmat(shiftdim(Kf,-1),nsamples,1,1,1);
    Kb_target = repmat(shiftdim(Kb,-1),nsamples,1,1,1);
else
    Kf_target = Kf;
    Kb_target = Kb;
end

Kfmse = squeeze(mse(K_est.scale*K_est.Kf, Kf_target, 1));
Kbmse = squeeze(mse(K_est.scale*K_est.Kb, Kb_target, 1));

end