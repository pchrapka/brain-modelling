%% exp13_lsl_error_vs_size_rc
%   Goal:
%   Test error of MQRDLSL algorithm as a function of number of parameters
test = false;

if test
    order = [2,4];
    channels = [2,4];
    
    norder = length(order);
    nchannels = length(channels);
    
    nsims = 2;
    nsamples = 1000;
    ntrials = 1;
    nsamples_mse = 10;
else
    order = [2,4,6,8,10];
    channels = [2,4,6,8,10,12,14];
    
    norder = length(order);
    nchannels = length(channels);
    
    nsims = 10;
    nsamples = 1000;
    ntrials = 10;
    nsamples_mse = 10;
end

outdir = fullfile(pwd,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% allocate mem
%results = [];
% results.ms_inno_error = zeros(nchannels,norder);
% results.rev = zeros(nchannels,norder);
mse_mean = zeros(nchannels,norder);
nmse_mean = zeros(nchannels,norder);
files = {};

setup_parfor();
for i=1:nchannels
    for j=1:norder
        % allocate mem
        trace = cell(nsims,1);
        estimate = cell(nsims,1);
        kf_true_sims = cell(nsims,1);
        data_simulated = cell(nsims,1);
        fresh = false(nsims,1);
        
        order_cur = order(j);
        channels_cur = channels(i);
        
        % simulate data
        parfor k=1:nsims
            
            % set up output file for sim data
            slug_sim = sprintf('vrc-p%d-c%d-s%d',order_cur,channels_cur,k);
            outfile_sim = fullfile(outdir,[slug_sim '.mat']);
            
            if ~exist(outfile_sim,'file')
                fprintf('simulating: %s\n', slug_sim);
                
                %% generate VRC
                s = VRC(channels_cur, order_cur);
                ncoefs = channels_cur^2*order_cur;
                sparsity = 0.1;
                ncoefs_sparse = ceil(ncoefs*sparsity);
                s.coefs_gen_sparse(...
                    'structure','fullchannels',...
                    'mode','exact',...
                    'ncoefs',ncoefs_sparse,...
                    'ncouplings',ceil(ncoefs_sparse/4),...
                    'stable',true,'verbose',1);
                
                % allocate mem for data
                x = zeros(channels_cur,nsamples,ntrials);
                for m=1:ntrials
                    [~,x(:,:,m),~] = s.simulate(nsamples);
                end
                
                kf_true = repmat(shiftdim(s.Kf,2),[1,1,1,nsamples]);
                kf_true = shiftdim(kf_true,3);
                
                kb_true = repmat(shiftdim(s.Kb,2),[1,1,1,nsamples]);
                kb_true = shiftdim(kb_true,3);
                
                % simulate data
                [X,X_norm,noise] = s.simulate(2*nsamples);
                
                % save vars for later
                data_simulated{k} = X;
                kf_true_sims{k} = kf_true;
                
                % save data
                data = [];
                data.kf_true = kf_true;
                data.simulated = data_simulated{k};
                save_parfor(outfile_sim,data);
                
                % set flag that new simulated is available
                fresh(k) = true;
            else
                fprintf('loading: %s\n', slug_sim);
                % load data
                data = loadfile(outfile_sim);
                kf_true_sims{k} = data.kf_true;
                data_simulated{k} = data.simulated;
            end
            
        end
        
        lambda = 0.99;
        filter_main = MQRDLSL1(channels_cur,order_cur,lambda);
        slug_filter = filter_main.name;
        slug_filter = strrep(slug_filter,' ','-');
        
        parfor k=1:nsims
            % set up output file for data
            
            slug_sim = sprintf('%s-s%d',slug_filter,k);
            outfile = fullfile(outdir,[slug_sim '.mat']);
            
            if fresh(k) || ~exist(outfile,'file')
                fprintf('running: %s\n', slug_sim);
                
                %% Set up filter
                lambda = 0.99;
                filter = MQRDLSL1(channels_cur,order_cur,lambda);
                %filter = MQRDLSL2(channels_cur,order_cur,lambda);
                trace{k} = LatticeTrace(filter,'fields',{'Kf'});
                
                %% Estimate coefs using lattice filter
                
                % run the filter
                warning('off','all');
                data_temp = data_simulated{k};
                trace{k}.run(data_temp(:,:,1),'verbosity',0);
                warning('on','all');
                
                estimate{k} = trace{k}.trace.Kf(nsamples+1:end,:,:,:);
                
                % save data
                data = [];
                data.estimate = estimate{k};
                save_parfor(outfile,data);
            else
                fprintf('loading: %s\n', slug_sim);
                % load data
                data = loadfile(outfile);
                estimate{k} = data.estimate;
            end
        end
        
        %% Plot MSE
        h = figure;
        plot_mse_vs_iteration(...
            estimate, kf_true_sims,...
            'mode','log',...
            'labels',{filter_main.name});
        
        save_fig_exp(mfilename('fullpath'),'tag',[slug_filter '-mse-full']);
        
        ylim([10^(-4) 10^3]);
        save_fig_exp(mfilename('fullpath'),'tag',[slug_filter '-mse']);
        close(h);
        
        %% Calculate final MSE
        
        data_mse = mse_iteration(estimate,kf_true_sims);
        data_mse = mean(data_mse,2);
        mse_mean(i,j) = mean(data_mse(nsamples-nsamples_mse+1:end));
        
        data_nmse = mse_iteration(estimate,kf_true_sims,'normalized',true);
        data_nmse = mean(data_nmse,2);
        nmse_mean(i,j) = mean(data_nmse(nsamples-nsamples_mse+1:end));
        
%         niter = nsamples;
%         nvars = numel(trace{k}.trace.Kf(nsamples+1:end,:,:,:))/niter;
%         estimate = reshape(trace{k}.trace.Kf(nsamples+1:end,:,:,:),niter,nvars);
%         truth = reshape(kf_true,niter,nvars);
%         mse_all = mse(estimate,truth,2);
%         mse_mean(i,j) = mean(mse_all(nsamples-nsamples_mse+1:end));
        
        
%         %% Calculate the relative error
%         % Section 3.3 in Schlogl2000
%         
%         % innovation error Lewis1990
%         inno_error = (trace{k}.trace.ferror(:,:,end)' - noise(:,nsamples+1:end)).^2;
%         ms_inno_error = sum(inno_error(:))/numel(inno_error);
%         
%         % relative error variance
%         % section 3.3 in Schlogl2000
%         X_steady = X(:,nsamples+1:end);
%         ms_signal = var(X_steady(:));
%         % all iterations, all channels, last order
%         last_ferror = trace{k}.trace.ferror(:,:,end);
%         ms_pred_error = var(last_ferror(:));
%         rev = ms_pred_error/ms_signal;
%         
%         % save results
%         results.ms_inno_error(i,j) = ms_inno_error;
%         results.rev(i,j) = rev;

%         %% Save results
%         result = [];
%         result.mse = mse_mean(i,j);
%         result.trace = trace;
%         result.process = s;
%         save(outfile,'result');
%         
%         files = [files, outfile];
    end
    
end

% %% Save list of data files
% outfile = 'data-files.mat';
% save(fullfile(outdir,outfile),files);

%% REV Plots
% x = repmat(channels',1,norder);
% y = repmat(order,nchannels,1);
% figure;
% surf(x,y,results.rev);
% title('Relative Error Variance');
% zlabel('REV');
% xlabel('Channels');
% ylabel('Order');
% 
% figure;
% surf(x,y,results.ms_inno_error);
% title('Innovation Error');
% zlabel('MSE');
% xlabel('Channels');
% ylabel('Order');

%% MSE Plots
x = repmat(channels',1,norder);
y = repmat(order,nchannels,1);
figure;
surf(x,y,mse_mean);
title('RC Error');
zlabel('MSE');
xlabel('Channels');
ylabel('Order');

save_fig_exp(mfilename('fullpath'),'tag','mse-all');

%% NMSE Plots
figure;
surf(x,y,nmse_mean);
title('RC Error');
zlabel('NMSE');
xlabel('Channels');
ylabel('Order');

save_fig_exp(mfilename('fullpath'),'tag','nmse-all');