function result = rc2pdc(Kf,Kb,Pf,varargin)
%RC2PDC converts RC to PDC
%   RC2PDC(Kf, Kb, Pf) converts RC to PDC
%
%   Input
%   -----
%   Kf
%       forward reflection coefficients, [order channels channels] or
%       [channels channels order]
%   Kb
%       backward reflection coefficients, [order channels channels] or
%       [channels channels order]
%   Pf  
%       forward prediction error covariance [channels channels]
%
%   Parameters
%   ----------
%   metric (string, default = 'euc')
%       metric for PDC
%   nfreqs (integer, default = 128)
%       number of frequency bins
%   specden (logical, default = false)
%       flag to compute spectral density
%   coherence (logical, default = false)
%       flag to compute spectrum
%   parfor (logical, default = false)
%       use parfor in pdc function, useful if only one pdc is being
%       computed
%   informat (string, default = '')
%       input format of coefs
%       'or-ch-ch'
%       'ch-ch-or'

p = inputParser();
addParameter(p,'parfor',false,@islogical);
addParameter(p,'specden',false,@islogical);
addParameter(p,'coherence',false,@islogical);
addParameter(p,'metric','euc',@ischar);
addParameter(p,'nfreqs',128,@isnumeric);
addParameter(p,'informat','',@(x) any(validatestring(x,{'ch-ch-or','or-ch-ch'})));
parse(p,varargin{:})

A2 = rcarrayformat(rc2ar(Kf,Kb,'informat',p.Results.informat),...
    'format',3,'informat',p.Results.informat,'transpose',false);

if p.Results.parfor
    tstart = tic;
    result = pdc_parfor(A2,Pf,'metric',p.Results.metric,'nfreqs',p.Results.nfreqs);
    telapsed = toc(tstart);
else
    tstart = tic;
    result = pdc(A2,Pf,'metric',p.Results.metric,'nfreqs',p.Results.nfreqs);
    telapsed = toc(tstart);
end
result.telapsed = telapsed;

if p.Results.specden
    result.SS = ss_alg(A2, Pf, p.Results.nfreqs);
else
    result.SS = [];
end

if p.Results.coherence
    result.coh = coh_alg(result.SS);
else
    result.coh = [];
end

end