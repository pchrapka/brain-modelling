function file_pdc_sig = pdc_bootstrap(lf_file,varargin)

p = inputParser();
addRequired(p,'lf_file',@ischar);
addParameter(p,'nresamples',100,@isnumeric);
addParameter(p,'pdc_params',{},@iscell);
addParameter(p,'alpha',0.05,@(x) x > 0 && x < 1);
parse(p,lf_file,varargin{:});

[outdir,filter_name,~] = fileparts(lf_file);
workingdirname = sprintf('%s-bootstrap',filter_name);
workingdir = fullfile(outdir,workingdirname);

threshold_stability = 10;

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
% use the middle part to avoid edge effects
nsamples_ends = ceil(0.05*nsamples);
resf((end-nsamples_ends+1):end,:,:) = [];
resf(1:nsamples_ends*2,:,:) = [];
nsamples_effective = size(resf,1);
% resb = datalf.estimate.berrord(:,:,:,norder);

% copy vars
nresamples = p.Results.nresamples;
filter_opts = {'lambda',datalf.filter.lambda,'gamma',datalf.filter.gamma};
lf_btstrp = cell(p.Results.nresamples,1);
% TODO switch back to parfor
parfor i=1:nresamples
% for i=1:nresamples
    resampledir = sprintf('resample%d',i);
    data_bootstrap_file = fullfile(workingdir, resampledir, sprintf('resample%d.mat',i));
    
    % check lf freshness
    fresh = isfresh(data_bootstrap_file, lf_file);
    
    if fresh || ~exist(data_bootstrap_file,'file')
        % use all trials to generate one bootstrapped data set
        data_bootstrap = zeros(nchannels,nsamples,ntrials);
        for j=1:ntrials
            stable = false;
            while ~stable
                % resample residual
                idx = randi(nsamples_effective,nsamples,1);
                res = resf(idx,:,j);
                
                % generate data
                % NOTE it should already be normalized since we're using
                % the power from the filtered process
                [data_bootstrap(:,:,j),~,~] = process.simulate(nsamples,...
                    'type_noise','input','noise_input',res');
                
                % check stability
                check_data = false;
                if check_data
                    hold off;
                    plot(data_bootstrap(:,:,j)');
                    
                    prompt = 'hit any key to continue';
                    resp = input(prompt,'s');
                end
                
                %plot(data_bootstrap(:,:,j)');
                data_max = max(max(abs(data_bootstrap(:,:,j))));
                if data_max > threshold_stability
                    fprintf('%s: resample %d, trial %d: not stable\n',mfilename,i,j);
                else
                    fprintf('%s: resample %d, trial %d: stable\n',mfilename,i,j);
                    stable = true;
                end
                
            end
        end
        % save generated data
        % NOTE i don't think it's necessary to save the generated data once it's
        % filtered, but i would then need to check the freshness of the
        % filter file and i don't have access to that here
        % hopefully the generated file isn't too big...
        save_parfor(data_bootstrap_file, data_bootstrap);
        %clear data_bootstrap;
    else
        fprintf('%s: resample %d already exists\n',mfilename,i);
    end
    
    % set up lattice filter
    filters = {};
    filters{1} = MCMTLOCCD_TWL4(nchannels, norder, ntrials, filter_opts{:});
    
    fprintf('%s: filtering resample %d\n',mfilename,i);
    % lattice filter
    lf_btstrp(i) = run_lattice_filter(...
        data_bootstrap_file,...
        'basedir',fullfile(workingdir,'fake.m'),...
        'outdir',resampledir,...
        'filters', filters,...
        'warmup_noise', true,...
        'warmup_data', true,...
        'force',false,...
        'verbosity',0,...
        'tracefields',{'Kf','Kb','Rf'},...
        'plot_pdc', false);
    
end

%% compute pdc
% compute pdc for all files
% already takes care of freshness and existence
pdc_file = rc2pdc_dynamic_from_lf_files(lf_btstrp,'params',p.Results.pdc_params);

% get pdc size
result = loadfile(pdc_file{1});
pdc_dims = size(result.pdc);
nsamples_data = pdc_dims(1);

% split up pdc by sample
% loop over pdc files
pdc_file_sample = cell(size(pdc_file,1),nsamples_data);
parfor i=1:nresamples
    fprintf('%s: splitting pdc %d/%d\n',mfilename,i,length(pdc_file));
    result = [];
    
    % loop over samples in pdc
    for j=1:nsamples_data
        % set up output file
        pdc_file_sample{i,j} = strrep(pdc_file{i},'.mat',sprintf('-sample%d.mat',j));
        fresh = isfresh(pdc_file_sample{i,j},pdc_file{i});
        if fresh || ~exist(pdc_file_sample{i,j},'file')
            fprintf('%s: splitting pdc sample %d/%d\n',mfilename,j,nsamples_data);
            if isempty(result)
                % only load pdc once
                result = loadfile(pdc_file{i});
            end
            
            result_new = [];
            result_new.pdc = result.pdc(j,:,:,:);
            save_parfor(pdc_file_sample{i,j}, result_new);
        end
    end
    
end

%% compute significance levels

% get tag between [pdc-dynamic-...].mat
pattern = '.*(pdc-dynamic-.*).mat';
result = regexp(pdc_file{1},pattern,'tokens');
pdc_tag = result{1}{1};

% create pdc signifiance file name
outfilename = sprintf('%s-sig-n%d-alpha%0.2f.mat',...
    pdc_tag, nresamples, p.Results.alpha);
file_pdc_sig = fullfile(workingdir, outfilename);

% fresh = isfresh(file_pdc_sig, lf_file);
fresh = cellfun(@(x) isfresh(file_pdc_sig, x), pdc_file, 'UniformOutput', true);
if any(fresh) || ~exist(file_pdc_sig,'file')
    
    % collect pdc results for each sample
    % otherwise the data set gets too big
    pdc_sig = nan(pdc_dims);
    pdc_file_sampleT = pdc_file_sample';
    parfor j=1:nsamples_data
        fprintf('%s: computing percentile for sample %d/%d\n',...
            mfilename,j,nsamples_data);
        
        outfile = fullfile(workingdir, 'bootstrap-by-samples',...
            sprintf('sample%d-n%d.mat',j,nresamples));
        fresh = cellfun(@(x) isfresh(outfile, x), pdc_file_sampleT{j,:}, 'UniformOutput', true);
        if any(fresh) || ~exist(outfile,'file')
        
            fprintf('%s: reorganizing resamples\n',mfilename);
            pdc_all = nan([nresamples, pdc_dims(2:end)]);
        
            % collect results from all resamplings
            for i=1:nresamples
                % collect results
                result = loadfile(pdc_file_sampleT{j,i});
                pdc_all(i,:,:,:) = result.pdc(:,:,:);
            end
            save_parfor(outfile, pdc_all)
        else
            pdc_all = loadfile(outfile);
        end
        
        % compute significance level for alpha
        pct = (1-p.Results.alpha)*100;
        pdc_sig(j,:,:,:) = prctile(pdc_all,pct,1);
    end
    
    % save pdc significance levels
    save_parfor(file_pdc_sig,pdc_sig);
end


end