%% exp13_lsl_error_vs_size_rc
%   Goal:
%   Test error of MQRDLSL algorithm as a function of number of parameters

order = [2,4,6,8,10];
channels = [2,4,6,8,10,12,14];

norder = length(order);
nchannels = length(channels);

nsamples = 1000;
ntrials = 1;
nsamples_mse = 10;

outdir = fullfile(pwd,'output');
if ~exist(outdir,'dir')
    mkdir(outdir);
end

% allocate mem
%results = [];
% results.ms_inno_error = zeros(nchannels,norder);
% results.rev = zeros(nchannels,norder);
mse_mean = zeros(nchannels,norder);
files = {};
parfor i=1:nchannels
    for j=1:norder
        %% Set up filter
        % channels from above
        % order from above
        lambda = 0.99;
        filter = MQRDLSL2(channels(i),order(j),lambda);
        trace = LatticeTrace(filter,'fields',{'Kf'});
        
        slug = trace.name;
        slug = strrep(slug,' ','-');
%         outfile = fullfile(outdir,[slug '.mat']);
%         if exist(outfile,'file')
%             fprintf('skipping %s, already exists\n',trace.name);
%             break;
%         end
        
        %% generate VRC
        s = VRC(channels(i),order(j));
        ncoefs = channels(i)^2*order(j);
        sparsity = 0.1;
        ncoefs_sparse = ceil(ncoefs*sparsity);
        s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse);
        
        % allocate mem for data
        x = zeros(channels(i),nsamples,ntrials);
        for k=1:ntrials
            [~,x(:,:,k),~] = s.simulate(nsamples);
        end
        
        kf_true = repmat(shiftdim(s.Kf,2),1,1,1,nsamples);
        kf_true = shiftdim(kf_true,3);
        
        kb_true = repmat(shiftdim(s.Kb,2),1,1,1,nsamples);
        kb_true = shiftdim(kb_true,3);
        
        % simulate data
        [X,X_norm,noise] = s.simulate(2*nsamples);
        
        %% Estimate coefs using lattice filter
        
        % run the filter
        trace.run(X(:,:,1),'verbosity',0);
        
        %% Plot MSE
        figure;
        plot_mse_vs_iteration(...
            trace.trace.Kf, kf_true,...
            'mode','log',...
            'labels',{trace.filter.name});
        
        save_fig_exp(slug,'tag','mse');
        
        %% Calculate final MSE
        
        niter = nsamples;
        nvars = numel(trace.trace.Kf(nsamples+1:end,:,:,:))/niter;
        estimate = reshape(trace.trace.Kf(nsamples+1:end,:,:,:),niter,nvars);
        truth = reshape(kf_true,niter,nvars);
        mse_all = mse(estimate,truth,2);
        mse_mean(i,j) = mean(data_mse(nsamples-nsamples_mse+1:end));
        
        
%         %% Calculate the relative error
%         % Section 3.3 in Schlogl2000
%         
%         % innovation error Lewis1990
%         inno_error = (trace.trace.ferror(:,:,end)' - noise(:,nsamples+1:end)).^2;
%         ms_inno_error = sum(inno_error(:))/numel(inno_error);
%         
%         % relative error variance
%         % section 3.3 in Schlogl2000
%         X_steady = X(:,nsamples+1:end);
%         ms_signal = var(X_steady(:));
%         % all iterations, all channels, last order
%         last_ferror = trace.trace.ferror(:,:,end);
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

%% Save list of data files
outfile = 'data-files.mat';
save(fullfile(outdir,outfile),files);

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