function lattice_filter_sources(files_in,files_out,opt)
%LATTICE_FILTER_SOURCES filters brain sources using a lattice filter
%   LATTICE_FILTER_SOURCES filters brain sources using a lattice filter.
%   formatted for use with PSOM pipeline
%
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
%   verbose (integer, default = 0)
%       verbosity level, options: 0,1

p = inputParser;
addRequired(p,'files_in',@iscell);
addRequired(p,'files_out',@iscell);
addParameter(p,'order',4,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'verbose',0);
parse(p,files_in,files_out,opt{:});

plot_ref_coefs = false;

% load one data set to get dims
data = ftb.util.loadvar(files_in{1});
nchannels = sum(data.inside);
nsamples = length(data.time);

ntrials = length(files_in);
parfor i=1:ntrials
% for i=1:ntrials
    if p.Results.verbose > 1
        fprintf('trial %d\n',i);
    end
    
    % load data
    data = ftb.util.loadvar(files_in{i});
    
    % set up lattice filter
    lattice = [];
    % lattice.alg = MQRDLSL1(nchannels, p.Results.order, p.Results.lambda);
    lattice.alg = MQRDLSL2(nchannels, p.Results.order, p.Results.lambda);
    lattice.scale = 1;
    lattice.name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',...
        nchannels, p.Results.order, p.Results.lambda);
    lattice.label = data.label;
    
    % initialize lattice filter with noise
    mu = zeros(nchannels,1);
    sigma = eye(nchannels);
    noise = mvnrnd(mu,sigma,nsamples)';
    warning('off','all');
    lattice = estimate_reflection_coefs(lattice, noise, p.Results.verbose);
    warning('on','all');
    
    % get source data
    temp = data.avg.mom(data.inside);
    % convert to matrix [patches x time]
    sources = cell2mat(temp);
    
    % normalize variance of each channel to unit variance
    X_norm = sources./repmat(std(sources,0,2),1,nsamples);
    
    % estimate the reflection coefficients
    [lattice,errors] = estimate_reflection_coefs(lattice, X_norm, p.Results.verbose);
%     if sum([errors.warning]) > 0
%         fprintf('\tfound errors\n');
%     end
%     % remove trial if there are errors
%     last_error = find([errors.warning],1,'last');
%     if ~isempty(last_error)
%         fprintf('\tlast error at sample %d\n',last_error);
%         fprintf('\tskipping trial\n')
%         break;
%     end
    
    % plot
    if plot_ref_coefs
        for ch1=1:nchannels
            for ch2=ch1:nchannels
                figure;
                Kest_stationary = zeros(p.Results.order,nchannels,nchannels);
                k_true = repmat(squeeze(Kest_stationary(:,ch1,ch2)),1,nsamples);
                plot_reflection_coefs(lattice, k_true, nsamples, ch1, ch2);
            end
        end
    end
    
    % save only Kf, half memory size
    lattice = rmfield(lattice,'Kb');
    % chop off the prestimulus, a bit less memory
    idx = data.time < 0;
    lattice.Kf(idx,:,:,:) = [];
    
    % save lattice output
    if p.Results.verbose > 1
        fprintf('\tsaving trial %d\n',i);
    end
    save_parfor(files_out{i}, lattice);
end

end