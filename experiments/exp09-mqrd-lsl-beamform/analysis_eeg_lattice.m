function analysis_eeg_lattice(data,varargin)
%ANALYSIS_EEG_LATTICE passes each trial through a lattice filter
%   ANALYSIS_EEG_LATTICE(data,...) passes each trial through a lattice
%   filter. saves the output of each trial in a separate file.
%
%   Input
%   -----
%   data (struct array)
%       array of beamformed eeg trials. the struct requires a field 'label' defining
%       the data class
%
%       raw output is provided by analysis_eeg_beamform_patch, a subset of
%       the data can be selected using analysis_select_data.
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
%   
%   Output
%   ------
%   None

p = inputParser;
addRequired(p,'data',@isstruct);
addParameter(p,'order',4,@isnumeric);
addParameter(p,'lambda',0.99,@isnumeric);
addParameter(p,'verbose',0);
addParameter(p,'outdir',fullfile(pwd,'output'));
parse(p,data,varargin{:});

fprintf('\n');
fprintf('Starting lattice filter\n');
fprintf('-----------------------\n');

if exist(p.Results.outdir,'dir')
    % delete previous files
    files = dir(fullfile(p.Results.outdir,'lattice*.mat'));
    for i=1:length(files)
        delete(fullfile(p.Results.outdir,files(i).name));
    end
end

plot_ref_coefs = false;

nchannels = sum(data(1).inside);
nsamples = length(data(1).time);
ntrials = length(data);
for i=1:ntrials
    fprintf('trial %d\n',i);
    
    % set up lattice filter
    lattice = [];
    % lattice.alg = MQRDLSL1(nchannels, p.Results.order, p.Results.lambda);
    lattice.alg = MQRDLSL2(nchannels, p.Results.order, p.Results.lambda);
    lattice.scale = 1;
    lattice.name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',...
        nchannels, p.Results.order, p.Results.lambda);
    lattice.label = data(i).label;
    
    % initialize lattice filter with noise
    mu = zeros(nchannels,1);
    sigma = eye(nchannels);
    noise = mvnrnd(mu,sigma,nsamples)';
    warning('off','all');
    lattice = estimate_reflection_coefs(lattice, noise, p.Results.verbose);
    warning('on','all');
    
    % get source data
    temp = data(i).avg.mom(data(i).inside);
    % convert to matrix [patches x time]
    sources = cell2mat(temp);
    
    % normalize variance of each channel to unit variance
    X_norm = normalizev(sources);
    
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
    idx = data(i).time < 0;
    lattice.Kf(idx,:,:,:) = [];
    
    % save lattice output
    out_file = fullfile(p.Results.outdir, sprintf('lattice%d.mat',i));
    save(out_file, 'lattice');
    fprintf('\tsaving trial %d\n',i);
end

end