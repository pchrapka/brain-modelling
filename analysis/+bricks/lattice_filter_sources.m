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
%   nout (scalar, default = 100)
%       number of outputs to produce
%   verbose (integer, default = 0)
%       verbosity level, options: 0,1

p = inputParser;
addRequired(p,'files_in',@ischar);
addRequired(p,'files_out',@ischar);
addParameter(p,'filter','MQRDLSL2',@ischar);
addParameter(p,'trials',1,@isnumeric);
addParameter(p,'nout',100,@isnumeric);
addParameter(p,'order',4,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'verbose',0);
parse(p,files_in,files_out,opt{:});

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
end

% load data
data_all = loadfile(files_in);
% get dims
nchannels = sum(data_all(1).inside);
nsamples = length(data_all(1).time);

% check how much data is available
nout = p.Results.nout;
if nout > length(data_all)
    nout = length(data_all);
    if p.Results.verbose > 0
        fprintf('\tusing %d trials instead of %d\n',nout,p.Results.nout);
    end
end

% set up multitrial groups
if p.Results.trials > 1
    % determine number of groups
    ntrial_groups = floor(nout/p.Results.trials);
    nout = ntrial_groups*p.Results.trials;
    
    % group trial files into groups, while omitting any extra trials
    data_in_groups = reshape(data_all(1:nout),p.Results.trials,ntrial_groups)';
    data_in = data_in_groups;
else
    ntrial_groups = nout;
    data_in = data_all(1:nout);
    data_in = data_in(:);
end
clear data_all;

[file_path,~,~] = fileparts(files_out);
file_list = cell(ntrial_groups,1);

parfor i=1:ntrial_groups
% for i=1:ntrial_groups
    if p.Results.verbose > 1
        fprintf('trial %d\n',i);
    end
    
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
            filter = MCMTMLOCCD_TWL2(nchannels, p.Results.order, p.Results.trials,...
                'lambda', p.Results.lambda,'gamma',gamma);
        case 'MQRDLSL2'
            filter = MQRDLSL2(nchannels, p.Results.order, p.Results.lambda);
        otherwise
            error('unknown filter %s',p.Results.filter)
    end
    
    % initialize lattice filter with noise
    mu = zeros(nchannels,1);
    sigma = eye(nchannels);
    noise = zeros(nchannels,nsamples,p.Results.trials);
    for j=1:p.Results.trials
        noise(:,:,j) = mvnrnd(mu,sigma,nsamples)';
    end
    warning('off','all');
    trace = LatticeTrace(filter,'fields',{'Kf'});
    trace.noise_warmup(noise);
    warning('on','all');
    
    X_norm = zeros(nchannels,nsamples,p.Results.trials);
    for j=1:p.Results.trials
        % load data
        data = data_in(i,j);
        
        % get source data
        sources = bf_get_sources(data);
        
        % normalize variance of each channel to unit variance
        X_norm(:,:,j) = sources./repmat(std(sources,0,2),1,nsamples);
    end
    
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
    if p.Results.verbose > 1
        fprintf('\tsaving trial group %d\n',i);
    end
    file_list{i} = fullfile(file_path,sprintf('trial%d.mat',i));
    save_parfor(file_list{i}, lattice);
end

% save trial list
save(files_out, 'file_list','-v7.3');

end