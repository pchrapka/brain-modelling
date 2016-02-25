%% exp06_mqrdlsl_error_vs_size
%
%  Goal:
%  Test the accuracy of MQRDLSL when there are many coefficients to
%  estimate

close all;

rng(1,'twister') % for reproducibility

params = [];
params.nchannels = [5 10 20 30 40];
params.order = 4;
params.nsamples = 1000;
params.nsamples_long = 10*params.nsamples;

doplot = false;
print_coefs = false;
mse_time = false;
mse_channels = true;

results = [];
[results(1:params.nchannels).Kfmse_avg] = deal(zeros(params.order,1));
[results(1:params.nchannels).Kbmse_avg] = deal(zeros(params.order,1));

for j=1:length(params.nchannels)
    order = params.order;
    nchannels = params.nchannels(j);
    nsamples = params.nsamples;
    
    results(j).nchannels_name = {sprintf('%d channels',nchannels)};
    
    s = VAR(nchannels, order);
    s.coefs_gen();
    if ~s.coefs_stable()
        error('coefs unstable for K=%d p=%d', nchannels, order);
    end
    results(j).var = s;

    %% Generate VAR
    % Simulate long signal to get a good estimate of the true reflection
    % coefficients, use lots of samples to get a good estimate of the truth
    [~,Y,~] = s.simulate(params.nsamples_long);
    
    % Use shorter signal length for adaptive algorithm
    X = Y(:,1:params.nsamples);
    
    if doplot
        % plot channels
        figure;
        for ch=1:nchannels
            subplot(nchannels,1,ch);
            plot(X(ch,:));
        end
    end
    
    %% Estimate the Reflection coefficients using a stationary approach
    % NOTE I have no way of generating a stable VAR process by specifying only
    % reflection coefficients
    % Use lots of samples to get a good estimate of the truth
    
    % Estimate reflection coefs using mvar
    [AR,RC,PE] = mvar(Y', order, 13);
    Aest = zeros(nchannels,nchannels,order);
    Kest_stationary = zeros(order,nchannels,nchannels);
    % TODO change all 3-d arrays to K,K,p
    for i=1:order
        idx_start = (i-1)*nchannels+1;
        idx_end = i*nchannels;
        Aest(:,:,i) = AR(:,idx_start:idx_end);
        Kest_stationary(i,:,:) = RC(:,idx_start:idx_end);

        if print_coefs
            fprintf('order %d\n\n',i);
            
            fprintf('VAR coefficients\n');
            fprintf('Actual\n');
            disp(s.A(:,:,i));
            fprintf('Estimated\n');
            disp(Aest(:,:,i));
            fprintf('\n');
            
            fprintf('Reflection coefficients\n');
            fprintf('Estimated\n');
            disp(squeeze(Kest_stationary(i,:,:)));
            fprintf('\n');
        end
        
    end
    %display(RC);
    
    %% Estimate the Reflection coefficients using the QRD-LSL algorithm
    
    verbose = false;
    % nchannels from above
    % order from above
    lambda = 0.99;
    lattice = [];
    lattice.alg = MQRDLSL1(nchannels,order,lambda);
    lattice.scale = -1;
    lattice.name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
    
    % estimate the reflection coefficients
    [lattice,errors] = estimate_reflection_coefs(lattice, X, verbose);
    if sum([errors.warning]) > 0
        error_idx = [errors.warning];
        % get error indices
        idx = 1:length(errors);
        error_mat = idx(error_idx);
        % set up formatting
        cols = 10;
        rows = ceil(length(error_mat)/cols);
        if length(error_mat) < cols*rows
            error_mat(cols*rows) = 0; % extend with 0
        end
        fprintf('warnings at:\n');
        for i=1:rows
            idx_start = (i-1)*cols + 1;
            idx_end = idx_start -1 + cols;
            row = error_mat(idx_start:idx_end);
            fprintf('\t');
            fprintf('%d ', row);
            fprintf('\n');
        end
    end
    
    %% Compare true and estimated
    
    % plot
    if doplot
        for ch1=1:nchannels
            for ch2=1:nchannels
                figure;
                k_true = repmat(squeeze(Kest_stationary(:,ch1,ch2)),1,nsamples);
                plot_reflection_coefs(lattice, k_true, nsamples, ch1, ch2);
            end
        end
    end
    
    % mse at each time point average over channels
    if mse_channels
        Kfmse = mse_coefs(lattice(1).scale*lattice(1).Kf, Kest_stationary, 'channels');
        Kbmse = mse_coefs(lattice(1).scale*lattice(1).Kb, Kest_stationary, 'channels');
        results(j).Kfmse = Kfmse;
        results(j).Kbmse = Kbmse;
    end

    if mse_time
        % mse
        Kfmse = mse_coefs(lattice(1).scale*lattice(1).Kf, Kest_stationary, 'time');
        Kbmse = mse_coefs(lattice(1).scale*lattice(1).Kb, Kest_stationary, 'time');
        for p=1:order
            error = Kfmse(p,:,:);
            results(j).Kfmse_avg(p) = mean(error(:));
            error = Kbmse(p,:,:);
            results(j).Kbmse_avg(p) = mean(error(:));
        end
    end
end

%% Plot
if mse_channels
    figure;
    for k=1:params.order
        subplot(params.order,1,k);
        for j=1:length(params.nchannels)
            plot(1:params.nsamples, log(results(j).Kfmse(:,k)))
            hold on;
        end
        ylabel(sprintf('order %d',k));
    end
    legend([results(:).nchannels_name]);
    
    figure;
    nsamples_skip = 200;
    for k=1:params.order
        subplot(params.order,1,k);
        for j=1:length(params.nchannels)
            plot(1:params.nsamples, results(j).Kfmse(:,k))
            xlim_cur = xlim;
            xlim([nsamples_skip xlim_cur(2)]);
            hold on;
        end
        ylabel(sprintf('order %d',k));
    end
    legend([results(:).nchannels_name]);
        
end

if mse_time
    figure;
    for j=1:length(params.nchannels)
        plot(1:order, results(j).Kfmse_avg);
        xlabel('order');
        ylabel('Kf avg MSE');
        hold on;
    end
    legend(results.nchannels_name);
end