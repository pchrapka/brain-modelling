function lattice_filter_sources(files_in,files_out,opt)
%LATTICE_FILTER_SOURCES filters brain sources using a lattice filter
%   LATTICE_FILTER_SOURCES filters brain sources using a lattice filter.
%   formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (string)
%       file name of sourceanalysis file processed by
%       ftb.BeamformerPatchTrial. the data struct needs to contain a label
%       field
%   files_out (string)
%       file name for list of filtered trials
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   order (integer, default = 4)
%       filter order
%   lambda (scalar, default = 0.99)
%       exponential weighting factor between 0 and 1
%   trials (scalar, default = 1)
%       number of trials to include for lattice filtering
%   nout (scalar, default = [])
%       number of outputs to produce
%   verbose (integer, default = 0)
%       verbosity level, options: 0,1

p = inputParser;
addRequired(p,'files_in',@(x) isfield(x,'warmup') && isfield(x,'data'));
addRequired(p,'files_out',@ischar);
addParameter(p,'filter','MQRDLSL2',@ischar);
addParameter(p,'trials',1,@isnumeric);
addParameter(p,'nout',[],@isnumeric);
addParameter(p,'order',4,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'verbose',0);
parse(p,files_in,files_out,opt{:});

disp(pwd);

% flag for plotting ref coefficients
plot_ref_coefs = false;

% check filter usage
if p.Results.trials > 1
    switch p.Results.filter
        case {'MCMTLOCCD_TWL2','MCMTQRDLSL1'}
            % ok
        otherwise
            error('Only MCMTQRDLSL1 is available for multiple trials');
    end
    
    if length(files_in.data) < p.Results.trials
        error('not enough data trials');
    end
    
    if length(files_in.warmup) < p.Results.trials
        error('not enough warmup trials');
    end
end

% load data
for i=1:length(files_in.data)
    din = loadfile(files_in.data{i});
    data_in(i) = din;
    din = loadfile(files_in.warmup{i});
    data_warmup(i) = din;
end

% get dims
nchannels = sum(data_in(1).inside);
nsamples = length(data_in(1).time);

% set up lattice filter
switch p.Results.filter
    case 'MCMTQRDLSL1'
        filter = MCMTQRDLSL1(nchannels, p.Results.order,p.Results.trials, p.Results.lambda);
    case 'MLOCCDTWL'
        sigma = 10^(-1);
        gamma = sqrt(2*sigma^2*nsamples*log(p.Results.order*nchannels^2));
        filter = MLOCCD_TWL(nchannels, p.Results.order,...
            'lambda', p.Results.lambda,'gamma',gamma);
    case 'MCMTLOCCD_TWL2'
        sigma = 10^(-1);
        gamma = sqrt(2*sigma^2*nsamples*log(p.Results.order*nchannels^2));
        filter = MCMTLOCCD_TWL2(nchannels, p.Results.order, p.Results.trials,...
            'lambda', p.Results.lambda,'gamma',gamma);
    case 'MQRDLSL2'
        filter = MQRDLSL2(nchannels, p.Results.order, p.Results.lambda);
    otherwise
        error('unknown filter %s',p.Results.filter)
end

trace = LatticeTrace(filter,'fields',{'Kf'});

% initialize lattice filter with noise
warning('off','all');
noise = gen_noise(nchannels, nsamples, p.Results.trials);
trace.warmup(noise);
warning('on','all');

X_norm = zeros(nchannels,nsamples,p.Results.trials);
X2_norm = X_norm;
for j=1:p.Results.trials
    % load data
    data = data_in(j);
    data2 = data_warmup(j);
    
    % get source data and normalize variance of each channel to unit variance
    X_norm(:,:,j) = normalizev(bf_get_sources(data));
    X2_norm(:,:,j) = normalizev(bf_get_sources(data2));
end

% warmup with data from previous trial
trace.run(X2_norm,'verbosity',p.Results.verbose,'mode','none');

% estimate the reflection coefficients
%warning('off','all');
trace.run(X_norm,'verbosity',p.Results.verbose,'mode','none');
%warning('on','all');

% plot
if plot_ref_coefs
    for ch1=1:nchannels
        for ch2=ch1:nchannels
            figure;
            trace.plot_trace(nsamples,'ch1',ch1,'ch2',ch2,...
                'title',sprintf('Reflection Coefficient Estimate C%d-%d',ch1,ch2));
        end
    end
end

% prep lattice data to save
lattice = trace.trace;
% copy data label
lattice.label = data.label;

% chop off the prestimulus, a bit less memory
idx = data.time < 0;
lattice.Kf(idx,:,:,:) = [];

% save lattice output
save_parfor(files_out, lattice);

end