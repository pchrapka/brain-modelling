function [A,Ab] = rc2ar(Kf,Kb)
%RC2AR converts RC to AR coefficients
%   RC2AR(Kf,Kb) converts RC to AR coefficients
%
%   Input
%   -----
%   Kf (matrix)
%       forward reflection coefficients, either [order channels channels]
%       or [channels channels order]
%   Kb (matrix)
%       backward reflection coefficients 
%
%   Output
%   ------
%   A (matrix)
%       autoregressive coefficients, [order channels channels]
%   Ab (matrix)
%       autoregressive coefficients, [order channels channels]

p = inputParser();
addRequired(p,'Kf',@(x) length(size(x)) <= 3);
addRequired(p,'Kb',@(x) length(size(x)) <= 3);
parse(p,Kf,Kb);

% check format
dims = size(Kf);
if length(dims) < 3
    dims(3) = 1;
end
if dims(1) == dims(2)
    norder = dims(3);
    nchannels = dims(1);
elseif dims(2) == dims(3)
    norder = dims(1);
    nchannels = dims(3);
else
    error('unknown coefficient format');
end

rc(:,:,1) = eye(nchannels);
rcb(:,:,1) = eye(nchannels);
rc(:,:,2:norder+1) = -1*rcarrayformat(Kf,'format',3);
rcb(:,:,2:norder+1) = -1*rcarrayformat(Kb,'format',3);

[par, parb] = rc2parv(rc,rcb);

A = -1*rcarrayformat(par(:,:,2:end),'format',1);
Ab = -1*rcarrayformat(parb(:,:,2:end),'format',1);
% TODO another format may be better

end