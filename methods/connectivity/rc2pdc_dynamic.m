function result = rc2pdc_dynamic(Kf,Kb,Pf,varargin)
%RC2PDC_DYNAMIC converts dynamic RC to dynamic PDC
%   RC2PDC_DYNAMIC(Kf, Kb, Pf) converts dynamic RC to dynamic PDC
%
%   Input
%   -----
%   Kf
%       forward reflection coefficients, [samples order channels channels]
%   Kb
%       backward reflection coefficients, [samples order channels channels]
%   Pf  
%       forward prediction error covariance [samples channels channels]
%
%   Parameters
%   ----------
%   metric (string, default = 'euc')
%       metric for PDC
%   specden (logical, default = false)
%       flag to compute spectral density
%   coherence (logical, default = false)
%       flag to compute spectrum
%   downsample (integer, default = 'none')
%       downsampling 

p = inputParser();
addRequired(p,'Kf',@(x) length(size(x)) == 4);
addRequired(p,'Kb',@(x) length(size(x)) == 4);
addRequired(p,'Pf',@(x) length(size(x)) == 3);
addParameter(p,'specden',false,@islogical);
addParameter(p,'coherence',false,@islogical);
addParameter(p,'metric','euc',@ischar);
addParameter(p,'downsample','none',@(x) isnumeric(x)  || isequal(x,'none'));
parse(p,Kf,Kb,Pf,varargin{:});

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

%% downsample
if ~isequal(p.Results.downsample,'none')
    fprintf('downsampling by %d\n',p.Results.downsample);
    % create index
    idx_mini = false(p.Results.downsample,1);
    idx_mini(1) = true;
    
    ntimes = floor(nsamples/p.Results.downsample);
    idx = repmat(idx_mini,ntimes,1);
    
    Kf = Kf(idx,:,:,:);
    Kb = Kb(idx,:,:,:);
    nsamples = size(Kf,1);
end 

%% get sizes for data strucs
%% pdc
fprintf('getting pdc data size\n');
Kftemp = squeeze(Kf(1,:,:,:));
Kbtemp = squeeze(Kb(1,:,:,:));
Pftemp = squeeze(Pf(1,:,:));
result = rc2pdc(Kftemp, Kbtemp, Pftemp,...
        'metric', options.metric,...
        'specden', options.specden,...
        'coherence', options.coherence,...
        'parfor', true);
result_pdc = zeros([nsamples size(result.pdc)]);

%% spectral density
if options.specden
    fprintf('getting ss data size\n');
    result_SS = zeros([nsamples size(result.SS)]);
else
    result_SS = zeros(nsamples,1);
end

%% coherence
if options.coherence
    fprintf('getting coherence data size\n');
    result_coh = zeros([nsamples size(result.coh)]);
else
    result_coh = zeros(nsamples,1);
end
clear result;

%% convert each sample
progbar = ProgressBar(nsamples);
parfor i=1:nsamples
    % update progress
    progbar.progress();
    
    Kftemp = squeeze(Kf(i,:,:,:));
    Kbtemp = squeeze(Kb(i,:,:,:));
    Pftemp = squeeze(Pf(i,:,:));
    pdc_sample = rc2pdc(Kftemp, Kbtemp, Pftemp,...
        'metric', options.metric,...
        'specden', options.specden,...
        'coherence', options.coherence,...
        'parfor', false);
    
    if options.specden
        result_SS(i,:,:,:) = pdc_sample.SS;
    end
    if options.coherence
        result_coh(i,:,:,:) = pdc_sample.coh;
    end
    
    % convert struct to more efficient data struct
    result_pdc(i,:,:,:) = pdc_sample.pdc;
    
end
progbar.stop();

% save results
result = [];
result.pdc = result_pdc;
if options.specden
    result.SS = result_SS;
end
if options.coherence
    result.coh = result_coh;
end

end