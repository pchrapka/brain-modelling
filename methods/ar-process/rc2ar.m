function [A,Ab] = rc2ar(Kf,Kb,varargin)
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
%   Parameters
%   ----------
%   informat (string, default = '')
%       input format of coefs
%       'or-ch-ch'
%       'ch-ch-or'
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
addParameter(p,'informat','',@(x) any(validatestring(x,{'ch-ch-or','or-ch-ch'})));
parse(p,Kf,Kb);

informat = p.Results.informat;
switch informat
    case 'ch-ch-or'
        [nchannels,~,norder] = size(Kf);
    case 'or-ch-ch'
        [norder,nchannels,~] = size(Kf);
    otherwise
        [format,nchannels,norder] = rc_check_format(Kf);
        if format == 3
            informat = 'ch-ch-or';
        else
            informat = 'or-ch-ch';
        end
end

rc(:,:,1) = eye(nchannels);
rcb(:,:,1) = eye(nchannels);
rc(:,:,2:norder+1) = -1*rcarrayformat(Kf,'format',3,'informat',informat);
rcb(:,:,2:norder+1) = -1*rcarrayformat(Kb,'format',3,'informat',informat);

[par, parb] = rc2parv(rc,rcb);

A = -1*rcarrayformat(par(:,:,2:end),'format',1,'informat','ch-ch-or');
Ab = -1*rcarrayformat(parb(:,:,2:end),'format',1,'informat','ch-ch-or');
% TODO another format may be better

end