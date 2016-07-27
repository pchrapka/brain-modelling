% exp30_tvar_vs_nchannels

[srcdir,func_name,~] = fileparts(mfilename('fullpath'));
outdir = fullfile(srcdir,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% set up params
nsims = 20;
channels = [2 4 6 8 10 12 14 16];
% channels = [2 4];
nchannel_opts = length(channels);

order_est = 10;

verbosity = 0;

filter_types = {...
    'MQRDLSL1',...
    'MQRDLSL2',...
    'MCMTQRDLSL1',...
    'MLOCCDTWL',...
    };

%% loop over params

large_error = false(nchannel_opts,nsims);
for k=1:length(filter_types)
    % allocate mem
    labels = cell(nchannel_opts,1);
    data_args = [];

    filter_type = filter_types{k};
    for i=1:nchannel_opts
        nchannels = channels(i);
        
        trace = cell(nsims,1);
        estimate = cell(nsims,1);
        kf_true_sims = cell(nsims,1);
        data_sim = cell(nsims,1);
        fresh = false(nsims,1);
        
        %for j=1:nsims
        parfor j=1:nsims
            
            % set up output file for sim data
            slug_sim = sprintf('vrc-tvar-p%d-c%d-s%d',order_est,nchannels,j);
            outfile_sim = fullfile(outdir,[slug_sim '.mat']);
            
            if ~exist(outfile_sim,'file')
                fprintf('simulating: %s\n', slug_sim);
                
                % generate data
                data = exp30_gen_tvar(nchannels);
                % save data
                save_parfor(outfile_sim,data);
                
                % copy data for filtering
                kf_true_sims{j} = data.true;
                data_sim{j} = data;
                
                % set flag that new simulated is available
                fresh(j) = true;
            else
                fprintf('loading: %s\n', slug_sim);
                
                % load data
                data = loadfile(outfile_sim);
                
                % copy data for filtering
                kf_true_sims{j} = data.true;
                data_sim{j} = data;
            end
        end
        
        % set up filter slug
        [filter_main,~] = exp30_get_filter(filter_type,nchannels);
        
        slug_filter = filter_main.name;
        slug_filter = strrep(slug_filter,' ','-');
        
        parfor j=1:nsims
            %for j=1:nsims
            slug_sim = sprintf('vrc-tvar-p%d-c%d-s%d',order_est,nchannels,j);
            slug_sim_filt = sprintf('%s-%s',slug_sim,slug_filter);
            outfile = fullfile(outdir,[slug_sim_filt '.mat']);
            
            if fresh(j) || ~exist(outfile,'file')
                fprintf('running: %s\n', slug_sim_filt)
                sources = data_sim{j}.signal;
                
                [filter,mt] = exp30_get_filter(filter_type,nchannels);
                trace{j} = LatticeTrace(filter,'fields',{'Kf'});
                
                ntime = size(sources,2);
                mu = zeros(nchannels,1);
                sigma = eye(nchannels);
                noise = zeros(nchannels,ntime,mt);
                for m=1:mt
                    noise(:,:,m) = mvnrnd(mu,sigma,ntime)';
                end
                trace_noise = LatticeTrace(filter,'fields',{'Kf'});
                
                warning('off','all');
                % run filter on noise
                trace_noise.run(noise,'verbosity',verbosity,'mode','none');
                
                % run the filter on data
                trace{j}.run(sources(:,:,1:mt),'verbosity',verbosity,'mode','none');
                warning('on','all');
                
                trace{j}.name = trace{j}.filter.name;
                
                estimate{j} = trace{j}.trace.Kf;
                
                % save data
                data = [];
                data.estimate = estimate{j};
                save_parfor(outfile,data);
            else
                fprintf('loading: %s\n', slug_sim_filt);
                % load data
                data = loadfile(outfile);
                estimate{j} = data.estimate;
            end
            
            data_mse = mse_iteration(estimate{j},kf_true_sims{j});
            if any(data_mse > 10^5)
                large_error(i,j) = true;
            end
        end
        
        % plot MSE for each sim
        for j=1:nsims
            figure;
            clf;
            plot_mse_vs_iteration(...
                estimate{j}, kf_true_sims{j},...
                'mode','log',...
                'labels',{sprintf('%d channels',nchannels)});
            drawnow;
            save_fig_exp(mfilename('fullpath'),'tag',sprintf('mse-%s-s%d',slug_filter,j));
        end
        
        data_args = [data_args {estimate kf_true_sims}];
        labels{i} = sprintf('%d channels',nchannels);
    end
    
    %% Plot MSE
    
    h = figure;
    clf;
    plot_mse_vs_iteration(...
        data_args{:},...
        'mode','log',...
        'labels',labels);
    drawnow;
    save_fig_exp(mfilename('fullpath'),'tag',sprintf('mse-all-%s',slug_filter));
end

%% Print extra info
fprintf('large errors\n');
for i=1:nchannel_opts
    nchannels = channels(i);
    for j=1:nsims
        if large_error(i,j)
            fprintf('\tc%d-s%d\n',nchannels,j);
        end
    end
end

