function run_lattice_benchmark(exp_path,varargin)
%
%   Input
%   -----
%   exp_path (string)
%       experiment's full file name
%       example:
%           exp_path = mfilename('fullpath');
%
%   Parameters
%   ----------
%   name (string)
%       benchmark name
%   sim_params (struct array)
%       array of benchmark parameters, including the following fields
%       filter (object)
%           filter Object
%       data (string)
%           data generator name
%       label (string)
%           data label for plots
%   warmup_noise (logical, default = true)
%       flag for warming up the filter with noise, this helps with filter
%       initialization
%   warmup_data (logical, default = false)
%       flag for warming up the filter with simulated data, this helps with
%       filter initialization
%   warmup_data_nsims (integer, default = 1)
%       selects number of sims to pass through filter for warmup, relevant
%       only if warmup_data = true
%   nsims (integer)
%       number of simulations to average
%   force (logical, default = false)
%       force recomputation
%   verbosity (integer, default = 0)
%       verbosity level
%
%   plot_avg_mse (logical, default = true)
%       flag for plotting the averge MSE over all simulations
%   plot_avg_nmse (logical, default = true)
%       flag for plotting the averge NMSE over all simulations
%   plot_sim_mse (logical, default = false)
%       flag for plotting the individual MSE
%   plot_sim_nmse (logical, default = false)
%       flag for plotting the individual NMSE
%   plot_coef_values (logical, default = false)
%       plot histogram of unique reflection coefficient values

%% parse inputs
p = inputParser();
addRequired(p,'exp_path',@ischar);
addParameter(p,'name','',@ischar);
% options_data_name = {'var-no-coupling'};
% addParameter(p,'data_name','var-no-coupling',@(x) any(validatestring(x,options_data_name)));
addParameter(p,'sim_params',[]);
addParameter(p,'warmup_noise',true,@islogical);
addParameter(p,'warmup_data',false,@islogical);
addParameter(p,'warmup_data_nsims',1,@isnumeric);
addParameter(p,'nsims',1,@isnumeric);
addParameter(p,'force',false,@islogical);
addParameter(p,'verbosity',0,@isnumeric);
addParameter(p,'plot_avg_mse',true,@islogical);
addParameter(p,'plot_avg_nmse',true,@islogical);
addParameter(p,'plot_sim_mse',false,@islogical);
addParameter(p,'plot_sim_nmse',false,@islogical);
addParameter(p,'plot_coef_values',false,@islogical);
p.parse(exp_path,varargin{:});

% copy params
nsims = p.Results.nsims;
sim_params = p.Results.sim_params;
nsim_params = length(sim_params);

[expdir,~,~] = fileparts(p.Results.exp_path);
outdir = fullfile(expdir,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% set up parfor
setup_parfor();

%% loop over params

% allocate mem
data_args = [];
large_error = zeros(nsim_params,nsims);
large_error_name = cell(nsim_params,nsims);
labels = cell(nsim_params,1);

for k=1:nsim_params
    
    % copy sim parameters
    sim_param = sim_params(k);
    
    % allocate mem
    trace = cell(nsims,1);
    estimate = cell(nsims,1);
    kf_true_sims = cell(nsims,1);
    
    % figure out how many trials per sim
    if isprop(sim_param.filter,'ntrials')
        ntrials = sim_param.filter.ntrials;
    else
        ntrials = 1;
    end
    if p.Results.warmup_data
        nsims_generate = nsims + p.Results.warmup_data_nsims;
    else
        nsims_generate = nsims;
    end
    
    % load data
    nchannels = sim_param.filter.nchannels;
    var_gen = VARGenerator(sim_param.data, nsims_generate*ntrials, nchannels);
    if isfield(sim_param,'data_params')
        data_var = var_gen.generate(sim_param.data_params{:});
    else
        data_var = var_gen.generate();
    end
    % get the data time stamp
    data_time = get_timestamp(var_gen.get_file());
    
    % copy data
    sources = data_var.signal;
    data_true = data_var.true;
    
    % set up slugs
    [~,data_file,~] = fileparts(var_gen.get_file());
    slug_data = strrep(data_file,'_','-');
    
    slug_filter = sim_param.filter.name;
    slug_filter = strrep(slug_filter,' ','-');
    
    
    parfor j=1:nsims
    %for j=1:nsims
        fresh = false;
        
        slug_data_filt = sprintf('%s-s%d-%s',slug_data,j,slug_filter);
        outfile = fullfile(outdir,[slug_data_filt '.mat']);
        
        if exist(outfile,'file')
            % check freshness of data and filter analysis
            filter_time = get_timestamp(outfile);
            if data_time > filter_time
                fresh = true;
            end
        end
        
        if p.Results.force || fresh || ~exist(outfile,'file')
            fprintf('running: %s\n', slug_data_filt)
            
            trace{j} = LatticeTrace(sim_param.filter,'fields',{'Kf'});
            
            ntime = size(sources,2);
            
            % warmup filter with noise
            if p.Results.warmup_noise
                mu = zeros(nchannels,1);
                sigma = eye(nchannels);
                noise = zeros(nchannels,ntime,ntrials);
                for m=1:ntrials
                    noise(:,:,m) = mvnrnd(mu,sigma,ntime)';
                end
                
                % run filter on noise
                warning('off','all');
                trace{j}.warmup(noise);
                warning('on','all');
            end
            
            % warmup filter with simulated data
            if p.Results.warmup_data
                % use last
                sim_idx_start = (nsims-1)*ntrials + 1;
                sim_idx_end = sim_idx_start + ntrials - 1;
                
                % run filter on sim data
                warning('off','all');
                trace{j}.warmup(sources(:,:,sim_idx_start:sim_idx_end));
                warning('on','all');
            end
            
            % calculate indices to select simulation instances from data
            sim_idx_start = (j-1)*ntrials + 1;
            sim_idx_end = sim_idx_start + ntrials - 1;
            
            % run the filter on data
            warning('off','all');
            trace{j}.run(sources(:,:,sim_idx_start:sim_idx_end),...
                'verbosity',p.Results.verbosity,...
                'mode','none');
            warning('on','all');
            
            trace{j}.name = trace{j}.filter.name;
            
            estimate{j} = trace{j}.trace.Kf;
            kf_true_sims{j} = data_true;
            
            % save data
            data = [];
            data.estimate = estimate{j};
            save_parfor(outfile,data);
        else
            fprintf('loading: %s\n', slug_data_filt);
            % load data
            data = loadfile(outfile);
            estimate{j} = data.estimate;
            kf_true_sims{j} = data_true;
        end
        
        data_mse = mse_iteration(estimate{j},kf_true_sims{j});
        if any(data_mse > 10)
            large_error_name{k,j} = slug_data_filt;
            large_error(k,j) = true;
        end
    end
    
    % plot MSE for each sim
    if p.Results.plot_sim_mse
        for j=1:nsims
            h = figure;
            clf;
            plot_mse_vs_iteration(...
                estimate{j}, kf_true_sims{j},...
                'mode','log',...
                'labels',{sprintf('%d channels',nchannels)});
            % TODO fix labels
            drawnow;
            save_fig_exp(p.Results.exp_path,...
                'tag',sprintf('mse-%s-%s-s%d',sim_param.data,slug_filter,j));
            close(h);
        end
    end
    
    % plot NMSE for each sim
    if p.Results.plot_sim_nmse
        for j=1:nsims
            h = figure;
            clf;
            plot_mse_vs_iteration(...
                estimate{j}, kf_true_sims{j},...
                'mode','log',...
                'normalized',true,...
                'labels',{sprintf('%d channels',nchannels)});
            % TODO fix labels
            drawnow;
            save_fig_exp(p.Results.exp_path,...
                'tag',sprintf('nmse-%s-%s-s%d',sim_param.data,slug_filter,j));
            close(h);
        end
    end
    
    % plot unique reflection coefficient values
    if p.Results.plot_coef_values
        h = figure;
        clf;
        kf_unique = unique(kf_true_sims{1});
        hist(kf_unique,linspace(-1,1,20));
        drawnow;
%         save_fig_exp(p.Results.exp_path,...
%             'tag',sprintf('coefs-c%d-s%d',channels(i),j),...
%             'formats',{'png'});
        close(h);
    end
    
    data_args = [data_args {estimate kf_true_sims}];
    labels{k} = sim_param.label;
    
end

%% Plot MSE

tag = strrep(p.Results.name,' ','-');
tag = strrep(tag,'_','-');

if p.Results.plot_avg_mse
    h = figure;
    clf;
    plot_mse_vs_iteration(...
        data_args{:},...
        'mode','log',...
        'labels',labels);
    drawnow;
    save_fig_exp(p.Results.exp_path,'tag',sprintf('mse-all-%s',tag));
    
    ylim([10^(-4) 10^(0)]);
    drawnow;
    save_fig_exp(p.Results.exp_path,'tag',sprintf('mse-all-axis-%s',tag));
end

if p.Results.plot_avg_nmse
    h = figure;
    clf;
    plot_mse_vs_iteration(...
        data_args{:},...
        'mode','log',...
        'normalized',true,...
        'labels',labels);
    drawnow;
    save_fig_exp(p.Results.exp_path,'tag',sprintf('nmse-all-%s',tag));
    
    ylim([10^(-1) 10^(3)]);
    drawnow;
    save_fig_exp(p.Results.exp_path,'tag',sprintf('nmse-all-axis-%s',tag));
end

%% Print extra info
fprintf('large errors\n');
for k=1:nsim_params
    for j=1:nsims
        if large_error(k,j) > 0
            fprintf('\tfile: %s\n',large_error_name{k,j});
        end
    end
end

end