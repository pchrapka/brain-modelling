function lattice_filter_sources(files_in,files_out,opt)
%LATTICE_FILTER_SOURCES filters brain sources using a lattice filter
%   LATTICE_FILTER_SOURCES filters brain sources using a lattice filter.
%   formatted for use with PSOM pipeline
%
%   Input
%   -----
%   files_in (cell array)
%       file names of trials to process, see also bricks.select_data
%   files_out (cell array)
%       file names of filtered trials
%   opt (cell array)
%       function options specified as name value pairs
%   
%   Parameters
%   ----------
%   outdir (string)
%       output directory path, each trial is saved in it's own file
%       lattice[trial number].mat
%   order (integer, default = 4)
%       filter order
%   lambda (scalar, default = 0.99)
%       exponential weighting factor between 0 and 1
%   trials (scalar, default = 1)
%       number of trials to include for lattice filtering
%   verbose (integer, default = 0)
%       verbosity level, options: 0,1

p = inputParser;
addRequired(p,'files_in',@iscell);
addRequired(p,'files_out',@iscell);
addParameter(p,'order',4,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'trials',1,@isnumeric);
addParameter(p,'verbose',0);
parse(p,files_in,files_out,opt{:});

% flag for plotting ref coefficients
plot_ref_coefs = false;

% load one data set to get dims
data = ftb.util.loadvar(files_in{1});
nchannels = sum(data.inside);
nsamples = length(data.time);
clear data

% set up multitrial groups
ntrials = length(files_in);
if p.Results.trials > 1
    % determine number of groups
    ntrial_groups = floor(ntrials/p.Results.trials);
    ntrials = ntrial_groups*p.Results.trials;
    
    % group trial files into groups, while omitting any extra trials
    files_in_groups = reshape(files_in(1:ntrials),p.Results.trials,ntrial_groups)';
    files_in = files_in_groups;
else
    ntrial_groups = ntrials;
end

parfor i=1:ntrial_groups
% for i=1:ntrial_groups
    if p.Results.verbose > 1
        fprintf('trial %d\n',i);
    end
    
    % set up lattice filter
    if p.Results.trials > 1
        filter = MCMTQRDLSL1(p.Results.trials, nchannels, p.Results.order, p.Results.lambda);
    else
        filter = MQRDLSL2(nchannels, p.Results.order, p.Results.lambda);
    end
    
    % initialize lattice filter with noise
    mu = zeros(nchannels,1);
    sigma = eye(nchannels);
    noise = zeros(nchannels,nsamples,p.Results.trials);
    for j=1:p.Results.trials
        noise(:,:,j) = mvnrnd(mu,sigma,nsamples)';
    end
    warning('off','all');
    trace_noise = LatticeTrace(filter,'fields',{});
    trace_noise.run(noise,'verbosity',p.Results.verbose,'mode','none');
    warning('on','all');
    
    X_norm = zeros(nchannels,nsamples,p.Results.trials);
    for j=1:p.Results.trials
        % load data
        data = ftb.util.loadvar(files_in{i,j});
        
        % get source data
        temp = data.avg.mom(data.inside);
        % convert to matrix [patches x time]
        sources = cell2mat(temp);
        
        % normalize variance of each channel to unit variance
        X_norm(:,:,j) = sources./repmat(std(sources,0,2),1,nsamples);
    end
    
    % estimate the reflection coefficients
    trace = LatticeTrace(filter,'fields',{'Kf'});
    trace.run(X_norm,'verbosity',p.Results.verbose,'mode','none');
    
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
    save_parfor(files_out{i}, lattice);
end

end