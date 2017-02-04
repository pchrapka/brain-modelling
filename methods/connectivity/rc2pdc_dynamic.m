function result = rc2pdc_dynamic(Kf,Kb,varargin)
%RC2PDC_DYNAMIC converts dynamic RC to dynamic PDC
%   RC2PDC_DYNAMIC(Kf, Kb) converts dynamic RC to dynamic PDC
%
%   Input
%   -----
%   Kf
%       forward reflection coefficients, [samples order channels channels]
%   Kb
%       backward reflection coefficients, [samples order channels channels]
%
%   Parameters
%   ----------
%   metric (string, default = 'euc')
%       metric for PDC
%   specden (logical, default = false)
%       flag to compute spectral density
%   coherence (logical, default = false)
%       flag to compute spectrum

p = inputParser();
addRequired(p,'Kf',@(x) length(size(x)) == 4);
addRequired(p,'Kb',@(x) length(size(x)) == 4);
addParameter(p,'specden',false,@islogical);
addParameter(p,'coherence',false,@islogical);
addParameter(p,'metric','euc',@ischar);
parse(p,Kf,Kb,varargin{:});

if size(Kf) ~= size(Kb)
    error('mismatched dimensions for Kf and Kb');
end
dims = size(Kf);
nsamples = dims(1);
if dims(3) ~= dims(4)
    error('bad format, channels should be in last 2 dimensions');
end

options = copyfields(p.Results,[],...
    {'specden','coherence','metric'});

% Convert to PDC to get sizes
fprintf('getting data size\n');
result = rc2pdc(squeeze(Kf(1,:,:,:)),squeeze(Kb(1,:,:,:)));
result_pdc = zeros([nsamples size(result.pdc)]);
if options.specden
    result_SS = zeros([nsamples size(result.SS)]);
else
    result_SS = zeros(nsamples,1);
end
if options.coherence
    result_coh = zeros([nsamples size(result.coh)]);
else
    result_coh = zeros(nsamples,1);
end

% convert each sample
parfor i=1:nsamples
    
    fprintf('sample %d/%d\n',i,nsamples);
    
    Kftemp = squeeze(Kf(i,:,:,:));
    Kbtemp = squeeze(Kb(i,:,:,:));
    A2 = -rcarrayformat(rc2ar(Kftemp,Kbtemp),'format',3);
    
    nchannels = size(A2,1);
    pf = eye(nchannels);
    out = pdc(A2,pf,'metric',options.metric);
    if options.specden
        result_SS(i,:,:,:) = ss_alg(A2, pf, 128);
    end
    if options.coherence
        result_coh(i,:,:,:) = coh_alg(squeeze(result_SS(i,:,:,:)));
    end
    
    % convert struct to more efficient data struct
    if ~isequal(options.metric,'euc')
        error('set up struct conversion for metric %s',options.metric);
    else
        result_pdc(i,:,:,:) = out.pdc;
    end
    
end

% save results
result.pdc = result_pdc;
if options.specden
    result.SS = result_SS;
end
if options.coherence
    result.coh = result_coh;
end

end