function result = rc2pdc(Kf,Kb)
%RC2PDC converts RC to PDC
%   RC2PDC(Kf, Kb) converts RC to PDC
%
%   Input
%   -----
%   Kf
%       forward reflection coefficients, [order channels channels] or
%       [channels channels order]
%   Kb
%       backward reflection coefficients, [order channels channels] or
%       [channels channels order]

A2 = -rcarrayformat(rc2ar(Kf,Kb),'format',3);
nchannels = size(A2,1);
pf = eye(nchannels);
result = pdc(A2,pf,'metric','euc');
result.SS = ss_alg(A2, pf, 128);
result.coh = coh_alg(result.SS);

end