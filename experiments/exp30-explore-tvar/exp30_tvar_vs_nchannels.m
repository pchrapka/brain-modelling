% exp30_tvar_vs_nchannels

[srcdir,func_name,~] = fileparts(mfilename('fullpath'));
outdir = fullfile(srcdir,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

setup_parfor();

%% set up params
nsims = 20;
% channels = [2 4 6 8 10 12 14 16];
channels = [2 4];
nchannel_opts = length(channels);

order_est = 10;
lambda = 0.98;

verbosity = 0;

sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MQRDLSL1(nchannels,order_est,lambda);
    sim_params(k).data = 'vrc-2ch-coupling';
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name','',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MQRDLSL2(nchannels,order_est,lambda);
    sim_params(k).data = 'vrc-2ch-coupling';
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name','',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

sim_params = [];
for k=1:nchannel_opts
    nchannels = channels(k);
    sim_params(k).filter = MCMTQRDLSL1(5,nchannels,order_est,lambda);
    sim_params(k).data = 'vrc-2ch-coupling';
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name','',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);

sim_params = [];
ntime = 358;
sigma = 10^(-1);
for k=1:nchannel_opts
    nchannels = channels(k);
    % gamma = sqrt(2*sigma^2*ntime*log(norder*nchannels^2));
    gamma = sqrt(2*sigma^2*ntime*log(nchannels));
    sim_params(k).filter = MLOCCD_TWL(nchannels,order_est,'lambda',lambda,'gamma',gamma);
    sim_params(k).data = 'vrc-2ch-coupling';
    sim_params(k).label = sprintf('%d channels',nchannels);
end

run_lattice_benchmark(...
    mfilename('fullpath'),...
    'name','',...
    'sim_params', sim_params,...
    'nsims', 20,...
    'noise_warmup', true,...
    'plot_avg_mse', true,...
    'plot_avg_nmse', true);


% k=1;
% filters = [];
% filters(k).name = 'MQRDLSL1';
% filters(k).params = {'order',order_est,'lambda',lambda,'ntrials',1};
% k = k+1;
% 
% filters(k).name = 'MQRDLSL2';
% filters(k).params = {'order',order_est,'lambda',lambda,'ntrials',1};
% k = k+1;
% 
% filters(k).name = 'MCMTQRDLSL1';
% filters(k).params = {'order',order_est,'lambda',lambda,'ntrials',5};
% k = k+1;
% 
% filters(k).name = 'MLOCCDTWL';
% filters(k).params = {'order',order_est,'lambda',lambda,'ntrials',1};
% k = k+1;
% 
% 
% plot_individual = false;
% plot_coef_values = false;
% 
% %% loop over params
% 
% large_error = zeros(nchannel_opts,nsims);
% fresh = false(nchannel_opts,nsims);
% plotted_coef_values = false(nchannel_opts); % reset flag
% for k=1:length(filters)
%     % allocate mem
%     labels = cell(nchannel_opts,1);
%     data_args = [];
% 
%     filter_type = filters(k);
%     for i=1:nchannel_opts
%         nchannels = channels(i);
%         
%         trace = cell(nsims,1);
%         estimate = cell(nsims,1);
%         kf_true_sims = cell(nsims,1);
%         data_sim = cell(nsims,1);
%         
%         %for j=1:nsims
%         parfor j=1:nsims
%             
%             % set up output file for sim data
%             slug_sim = sprintf('vrc-tvar-p%d-c%d-s%d',order_est,nchannels,j);
%             outfile_sim = fullfile(outdir,[slug_sim '.mat']);
%             
%             if ~exist(outfile_sim,'file')
%                 fprintf('simulating: %s\n', slug_sim);
%                 
%                 % generate data
%                 data = exp30_gen_tvar(nchannels);
%                 % save data
%                 save_parfor(outfile_sim,data);
%                 
%                 % copy data for filtering
%                 kf_true_sims{j} = data.true;
%                 data_sim{j} = data;
%                 
%                 % set flag that the simulated data is new
%                 fresh(i,j) = true;
%             else
%                 fprintf('loading: %s\n', slug_sim);
%                 
%                 % load data
%                 data = loadfile(outfile_sim);
%                 
%                 % copy data for filtering
%                 kf_true_sims{j} = data.true;
%                 data_sim{j} = data;
%             end
%         end
%         
%         % set up filter slug
%         [filter_main,~] = exp30_get_filter(filter_type.name,...
%             'nchannels',nchannels,...
%             filter_type.params{:});
%         
%         slug_filter = filter_main.name;
%         slug_filter = strrep(slug_filter,' ','-');
%         
%         parfor j=1:nsims
%             %for j=1:nsims
%             slug_sim = sprintf('vrc-tvar-p%d-c%d-s%d',order_est,nchannels,j);
%             slug_sim_filt = sprintf('%s-%s',slug_sim,slug_filter);
%             outfile = fullfile(outdir,[slug_sim_filt '.mat']);
%             
%             if fresh(i,j) || ~exist(outfile,'file')
%                 fprintf('running: %s\n', slug_sim_filt)
%                 sources = data_sim{j}.signal;
%                 
%                 [filter,mt] = exp30_get_filter(filter_type.name,...
%                     'nchannels',nchannels,...
%                     filter_type.params{:});
%                 trace{j} = LatticeTrace(filter,'fields',{'Kf'});
%                 
%                 ntime = size(sources,2);
%                 mu = zeros(nchannels,1);
%                 sigma = eye(nchannels);
%                 noise = zeros(nchannels,ntime,mt);
%                 for m=1:mt
%                     noise(:,:,m) = mvnrnd(mu,sigma,ntime)';
%                 end
%                 trace_noise = LatticeTrace(filter,'fields',{'Kf'});
%                 
%                 warning('off','all');
%                 % run filter on noise
%                 trace_noise.run(noise,'verbosity',verbosity,'mode','none');
%                 
%                 % run the filter on data
%                 trace{j}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
%                 warning('on','all');
%                 
%                 trace{j}.name = trace{j}.filter.name;
%                 
%                 estimate{j} = trace{j}.trace.Kf;
%                 
%                 % save data
%                 data = [];
%                 data.estimate = estimate{j};
%                 save_parfor(outfile,data);
%             else
%                 fprintf('loading: %s\n', slug_sim_filt);
%                 % load data
%                 data = loadfile(outfile);
%                 estimate{j} = data.estimate;
%             end
%             
%             data_mse = mse_iteration(estimate{j},kf_true_sims{j});
%             if any(data_mse > 10)
%                 large_error(i,j) = large_error(i,j) + 1;
%             end
%         end
%         
%         % plot MSE for each sim
%         if plot_individual
%             for j=1:nsims
%                 h = figure;
%                 clf;
%                 plot_mse_vs_iteration(...
%                     estimate{j}, kf_true_sims{j},...
%                     'mode','log',...
%                     'labels',{sprintf('%d channels',nchannels)});
%                 drawnow;
%                 save_fig_exp(mfilename('fullpath'),'tag',sprintf('mse-%s-s%d',slug_filter,j));
%                 close(h);
%             end
%         end
%         
%         % plot unique reflection coefficient values
%         if plot_coef_values
%             if ~plotted_coef_values(i)
%                 for j=1:nsims
%                     h = figure;
%                     clf;
%                     kf_unique = unique(kf_true_sims{j});
%                     hist(kf_unique,linspace(-1,1,20));
%                     drawnow;
%                     save_fig_exp(mfilename('fullpath'),...
%                         'tag',sprintf('coefs-c%d-s%d',channels(i),j),...
%                         'formats',{'png'});
%                     close(h);
%                 end
%                 plotted_coef_values(i) = true; % do this only once per channel
%             end
%         end
%         
%         data_args = [data_args {estimate kf_true_sims}];
%         labels{i} = sprintf('%d channels',nchannels);
%     end
%     
%     %% Plot MSE
%     
%     h = figure;
%     clf;
%     plot_mse_vs_iteration(...
%         data_args{:},...
%         'mode','log',...
%         'labels',labels);
%     drawnow;
%     save_fig_exp(mfilename('fullpath'),'tag',sprintf('mse-all-%s',slug_filter));
%     ylim([10^(-4) 10^(0)]);
%     drawnow;
%     save_fig_exp(mfilename('fullpath'),'tag',sprintf('mse-all-axis-%s',slug_filter));
%     
%     h = figure;
%     clf;
%     plot_mse_vs_iteration(...
%         data_args{:},...
%         'mode','log',...
%         'normalized',true,...
%         'labels',labels);
%     drawnow;
%     save_fig_exp(mfilename('fullpath'),'tag',sprintf('nmse-all-%s',slug_filter));
%     ylim([10^(-1) 10^(3)]);
%     drawnow;
%     save_fig_exp(mfilename('fullpath'),'tag',sprintf('nmse-all-axis-%s',slug_filter));
% end
% 
% %% Print extra info
% fprintf('large errors\n');
% for i=1:nchannel_opts
%     nchannels = channels(i);
%     for j=1:nsims
%         if large_error(i,j) > 0
%             fprintf('\tc%d-s%d = %d/%d\n',nchannels,j,large_error(i,j),length(filters));
%         end
%     end
% end
% 
