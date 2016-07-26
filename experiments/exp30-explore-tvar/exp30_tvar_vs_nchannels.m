% exp30_tvar_vs_nchannels

[srcdir,func_name,~] = fileparts(mfilename('fullpath'));
outdir = fullfile(srcdir,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% set up params
nsims = 1;
channels = [2 4 6 8 10 12 14 16];
% channels = [2 4];
nchannel_opts = length(channels);

order_est = 10;
lambda = 0.98;

filter_type = 'MQRDLSL1';

%% loop over params

% allocate mem
labels = cell(nchannel_opts,1);
data_args = [];

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
    switch filter_type
        case 'MQRDLSL1'
            filter_main = MQRDLSL1(nchannels,order_est,lambda);
    end
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
            
            switch filter_type
                case 'MQRDLSL1'
                    filter = MQRDLSL1(nchannels,order_est,lambda);
                    mt = 1;
            end
            trace{j} = LatticeTrace(filter,'fields',{'Kf'});
            
            % run the filter
            warning('off','all');
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
    end
    
    data_args = [data_args {estimate kf_true_sims}];
    labels{i} = sprintf('%d channels',nchannels);
end

%% Plot MSE
    
h = figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels);
save_fig_exp(mfilename('fullpath'),'tag',sprintf('%s-mse',slug_filter,nchannels));