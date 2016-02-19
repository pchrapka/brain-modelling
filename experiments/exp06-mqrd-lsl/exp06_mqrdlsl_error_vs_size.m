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

doplot = false;

results = [];
results.Kfmse_avg = zeros(params.order, length(params.nchannels));
results.Kbmse_avg = results.Kfmse_avg;

for j=1:length(params.nchannels)
    order = params.order;
    nchannels = params.nchannels(j);
    nsamples = params.nsamples;
    
    resuls.nchannels_name(j) = {sprintf('%d channels',nchannels)};
    
    Kf = 0.082*ones(order, nchannels, nchannels);
    % Note a multiple of 0.1 is too big for the algo
    Kb = Kf;

    [~,X,noise] = gen_stationary_ar_lattice(Kf,Kb,nsamples);

    if doplot
        % plot channels
        figure;
        for ch=1:nchannels
            subplot(nchannels,1,ch);
            plot(X(ch,:));
        end
    end
    
    % % estimate AR coefs
    % for ch=1:nchannels
    %     [a_est, e] = lpc(X(ch,:), order)
    % end
    
    %% Estimate the Reflection coefficients using the QRD-LSL algorithm
    
    % nchannels from above
    % order from above
    lambda = 0.99;
    lattice = [];
    lattice.alg = MQRDLSL1(nchannels,order,lambda);
    lattice.scale = -1;
    lattice.name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
    
    % estimate the reflection coefficients
    lattice = estimate_reflection_coefs(lattice, X);
    
    %% Compare true and estimated
    
    % plot
    if doplot
        for ch1=1:nchannels
            for ch2=1:nchannels
                figure;
                k_true = repmat(squeeze(Kf(:,ch1,ch2)),1,nsamples);
                plot_reflection_coefs(lattice, k_true, nsamples, ch1, ch2);
            end
        end
    end
    
    % mse
    [Kfmse, Kbmse] = mse_reflection_coefs(lattice(1), Kf, Kb, true);
    for p=1:order
        error = Kfmse(p,:,:);
        results.Kfmse_avg(p,j) = mean(error(:));
        error = Kbmse(p,:,:);
        results.Kbmse_avg(p,j) = mean(error(:));
    end
end

%% Plot
figure;
for j=1:length(params.nchannels)
    plot(1:order, results.Kfmse_avg(:,j));
    xlabel('order');
    ylabel('Kf avg MSE');
    hold on;
end
legend(resuls.nchannels_name);