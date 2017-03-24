function outfile = pdc_bootstrap(lf_file,varargin)

p = inputParser();
addRequired(p,'lf_file',@ischar);
addParameter(p,'nresamples',100,@isnumeric);
addParameter(p,'pdc_params',{},@iscell);
addParameter(p,'alpha',0.05,@(x) x > 0 && x < 1);
parse(p,lf_file,varargin{:});

[outdir,filter_name,~] = fileparts(lf_file);
workingdirname = sprintf('%s-bootstrap',filter_name);
workingdir = fullfile(outdir,workingdirname);
error('run through with nresamples and check data file sizes');

%% create RCs for null distribution 
% null distribution - no coupling
% set off diagonal elements to zero

datalf = loadfile(lf_file);
ntrials = datalf.filter.ntrials;
[nsamples, norder, nchannels, ~] = size(datalf.estimate.Kf);

datalf_nocoupling = [];
datalf_nocoupling.Kf = datalf.estimate.Kf;
datalf_nocoupling.Kb = datalf.estimate.Kb;
% order channels channels
for i=1:nchannels
    for j=1:nchannels
        if i == j
            % do nothing
        else
            % remove couplings
            datalf_nocoupling.Kf(:,:,i,j) = 0;
            datalf_nocoupling.Kb(:,:,i,j) = 0;
        end
    end
end

% create TV RC class
process = VTVRC(nchannels,norder,nsamples);
process.coefs_set(datalf_nocoupling.Kf,datalf_nocoupling.Kb);

%% bootstrap data and lattice filter
resf = datalf.estimate.ferror(:,:,:,norder); % samples channels trials order
% resb = datalf.estimate.berrord(:,:,:,norder);

% copy vars
nresamples = p.Results.nresamples;
filter_opts = {'lambda',datalf.filter.lambda,'gamma',datalf.filter.gamma};
lf_btstrp = cell(p.Results.nresamples,1);
% TODO switch back to parfor
% parfor i=1:nresamples
for i=1:nresamples
    
    data_bootstrap_file = fullfile(workingdir, sprintf('bootstrap%d.mat',i));
    
    % check lf freshness
    fresh = isfresh(data_bootstrap_file, lf_file);
    
    if fresh || ~exist(data_bootstrap_file,'file')
        % use all trials to generate one bootstrapped data set
        data_bootstrap = zeros(nchannels,nsamples,ntrials);
        for j=1:ntrials
            stable = false
            while ~stable
                res = resf(:,:,j);
                % resample residual
                idx = randperm(nsamples);
                res = res(idx,:);
                
                % generate data
                % normalized or regular data?
                [data_bootstrap(:,:,j),~,~] = process.simulate(...
                    'type_noise','input','noise_input',res');
                
                % TODO check stability
                % if stable, stable = true
                plot(data_bootstrap(:,:,j));
                error('check stability')
                % TODO write your own stability checker, since i don't want
                % to simulate, i want to check the already simulated signal
                
            end
        end
        % TODO save generated data??
        % i don't think it's necessary to save the generated data once it's
        % filtered, but i would then need to check the freshness of the
        % filter file and i don't have access to that here
        % hopefully the generated file isn't too big...
        save_parfor(data_bootstrap_file, data_bootstrap);
        clear data_bootstrap;
    else
        fprintf('bootstrap %d already exists\n',i);
    end
    
    % set up lattice filter
    filters = {};
    filters{1} = MCMTLOCCD_TWL4(nchannels, norder, ntrials, filter_opts{:});
    tag = sprintf('perm%d',i);
    
    % lattice filter
    lf_btstrp{i} = run_lattice_filter(...
        data_bootstrap_file,...
        'basedir',workingdir,...
        'outdir',tag,...
        'filters', filters,...
        'warmup_noise', true,...
        'warmup_data', true,...
        'force',false,...
        'verbosity',false,...
        'tracefields',{'Kf','Kb','Rf'},...
        'plot_pdc', false);
    
end

%% compute pdc and significance level
nfreqs = 128; % FIXME shouldn't be hard coded
pdc_all = nan(p.Results.nresamples, nsamples, nchannels, nchannels, nfreqs);

% TODO remove as params, instead have pdc_params
% pdc_params = {...
%     'metric',p.Results.metric,...
%     'downsample',p.Results.downsample,...
%     };

% TODO  how big is this?
for i=1:p.Results.nresamples
    % compute pdc
    % already takes care of freshness and existence
    pdc_file = rc2pdc_dynamic_from_lf_files(lf_btstrp{i},'params',p.Results.pdc_params);
    
    result = loadfile(pdc_file);
    
    pdc_all(i,:,:,:,:) = result.pdc;
end

% NOTE this might be needed if pdc_all is really big
% % save into file for sample j
% outfile = fullfile(workingdir, sprintf('pdc-bootstrap-%s.mat',p.Results.metric));
% % TODO add output directory, use data dir
% save_parfor(outfile, pdc_all);

% compute significance level for alpha
pct = 1-p.Results.alpha;
pdc_sig = prctile(pdc_all,pct,1);

% save pdc significance levels
% TODO get tag between [pdc-dynamic-...].mat
pattern = '.*(pdc-dynamic-.*).mat';
result = regexp(pdc_file,pattern,'tokens');
pdc_tag = result{1}{1};
error('check this tag');

outfilename = sprintf('%s-sig-n%d-alpha%0.2f.mat',...
    pdc_tag, p.Results.nresamples, p.Results.alpha);
outfile = fullfile(workingdir, outfilename);
save_parfor(outfile,pdc_sig);


end