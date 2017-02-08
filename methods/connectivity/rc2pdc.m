function result = rc2pdc(Kf,Kb,varargin)
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
%
%   Parameters
%   ----------
%   metric (string, default = 'euc')
%       metric for PDC
%   specden (logical, default = false)
%       flag to compute spectral density
%   coherence (logical, default = false)
%       flag to compute spectrum
%   parfor (logical, default = false)
%       use parfor in pdc function, useful if only one pdc is being
%       computed

p = inputParser();
addParameter(p,'parfor',false,@islogical);
addParameter(p,'specden',false,@islogical);
addParameter(p,'coherence',false,@islogical);
addParameter(p,'metric','euc',@ischar);
parse(p,varargin{:})

A2 = rcarrayformat(rc2ar(Kf,Kb),'format',3,'transpose',false);
nchannels = size(A2,1);
pf = eye(nchannels);

if p.Results.parfor
    tstart = tic;
    result = pdc_parfor(A2,pf,'metric',p.Results.metric);
    telapsed = toc(tstart);
else
    tstart = tic;
    result = pdc(A2,pf,'metric',p.Results.metric);
    telapsed = toc(tstart);
end
result.telapsed = telapsed;

if p.Results.specden
    result.SS = ss_alg(A2, pf, 128);
else
    result.SS = [];
end

if p.Results.coherence
    result.coh = coh_alg(result.SS);
else
    result.coh = [];
end

end