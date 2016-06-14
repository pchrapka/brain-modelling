% exp19_krls_anomaly
% KRLS-T anomaly detection algorithm for the Lorenz attractor time-series.
%
% Adapted from the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

close all
clear all

%% PARAMETERS

horizon = 1; % prediction horizon
embedding = 2; % time-embedding
N = 500; % number of data

params_estimate = false;

%% PROGRAM
tic

fprintf(1,'Loading Lorenz attractor time-series...\n')
[X,Y_true] = kafbox_data(struct('file','lorenz.dat','horizon',horizon,...
    'embedding',embedding,'N',N));

% % add noise
% sigma_noise = 5;
% W = mvnrnd(0,sigma_noise,N);
% Y = Y_true + W;
Y = ones(size(Y_true));
%Y = Y_true;

% create data with anomalies
signal = load('lorenz.dat');
% % randomly select time points for anomalies
% nanomalies = 100;
% idx_anomaly = randsample(length(signal),nanomalies);
% % create random perturbations
% anomalies = mvnrnd(0,var(signal),nanomalies);
% % add perturbations to signal
% signal_perturbed = signal;
% signal_perturbed(idx_anomaly) = signal_perturbed(idx_anomaly) + anomalies;

% create constant anomaly
f = 10;
fs = 240;
t = linspace(0,length(signal)/fs,length(signal));
anomaly = sqrt(var(signal))*sin(2*pi*f*t)' + mean(signal);
signal_perturbed = signal;
idx_start = floor(N/2);
idx_anomaly = idx_start:length(signal);
signal_perturbed(idx_start:end) = anomaly(idx_start:end);
save('lorenz-anomalies.dat','signal_perturbed','-ascii');
%din = load('lorenz-anomalies.dat');

[X_test,Y_test] = kafbox_data(struct('file','lorenz-anomalies.dat','horizon',horizon,...
    'embedding',embedding,'N',N));

idx_anomaly2 = idx_anomaly(idx_anomaly<=N);
Y_test_true = ones(size(Y_test));
Y_test_true(idx_anomaly2) = 0;

if params_estimate
    fprintf(1,'Estimating KRLS-T parameters for %d-step prediction...\n\n',...
        horizon)
    [sigma_est,reg_est,lambda_est] = kafbox_parameter_estimation(X_test,Y_test_true);
    % NOTE The parameter estimation doesn't work as well as I'd expect
    
    fprintf('\n');
    fprintf('        Estimated\n');
    fprintf('sigma:  %.4f\n',sigma_est)
    fprintf('c:      %e\n',reg_est)
    fprintf('lambda: %.4f\n\n',lambda_est)
end

%%
Y_est = zeros(N,1);
Yvar_est = zeros(N,1);

if params_estimate
    fprintf(1,'Running KRLS-T with estimated parameters...\n')
    kaf = krlst(struct('lambda',lambda_est,'M',100,'sn2',reg_est,...
        'kerneltype','gauss','kernelpar',sigma_est));
else
    fprintf(1,'Running KRLS-T with hard coded parameters...\n')
    switch embedding
        case 2
            rho = 0.01;
            sigma = 0.65;
            lambda = 1;
        case 6
            %         rho = 0.01;
            %         sigma = 2;
            %         lambda = 1;
            
            rho = 0.01;
            sigma = 2;
            lambda = 0.999;
        otherwise
            error('figure params for this embedding');
    end
    kaf = krlst(struct('lambda',lambda,'M',100,'sn2',rho,...
        'kerneltype','gauss','kernelpar',sigma));
end

for i=1:N,
    if ~mod(i,floor(N/10)), fprintf('.'); end % progress indicator, 10 dots
    
    [Y_est(i), Yvar_est(i)] = kaf.evaluate(X(i,:)); % predict the next output
    kaf = kaf.train(X(i,:),Y(i)); % train with one input-output pair
    
end
fprintf('\n');
SE = (Y-Y_est).^2; % square error

toc
%% OUTPUT

% fprintf('\n');
% fprintf('        Estimated\n');
% fprintf('sigma:  %.4f\n',sigma_est)
% fprintf('c:      %e\n',reg_est)
% fprintf('lambda: %.4f\n\n',lambda_est)

fprintf('Average MSE after first 100 samples: %.2fdB\n\n',...
    10*log10(mean(SE(101:end))));

figure; hold all; plot(Y); plot(Y_est);
legend({'original','prediction'},'Location','SE');
title(sprintf('%d-step ahead prediction %s on Lorenz time series',...
    horizon,upper(class(kaf))));

%% plot variance
figure;
hold all;
t = (1:N)';
z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
for i=1:length(z)
    set(z(i),'FaceAlpha',0.3);
    set(z(i),'EdgeColor','None');
end
h(1) = plot(Y,'-g');
h(2) = plot(Y_est,'-r');
title('Variance');
ylim([-1 1.5]);
legend(h,{'observed','prediction'},'Location','SE');

%% test data with anomalies
fprintf(1,'Running KRLS-T on anomalies...\n')
Y_est = zeros(N,1);
Yvar_est = zeros(N,1);

for i=1:N,
    if ~mod(i,floor(N/10)), fprintf('.'); end % progress indicator, 10 dots
    
    [Y_est(i), Yvar_est(i)] = kaf.evaluate(X_test(i,:)); % predict the next output
    
end
fprintf('\n');
SE = (Y_test_true-Y_est).^2; % square error
fprintf('Average MSE over all samples: %.2fdB\n\n',...
    10*log10(mean(SE)));

figure;
hold all;
plot(Y_true);
plot(Y_test);
legend({'original','anomalies'});


figure;
hold all;
plot(1-Y_est);
plot(idx_anomaly2,zeros(size(idx_anomaly2)),'or');

legend({'estimated','anomalies'});

%% plot variance
figure;
hold all;
t = (1:N)';
z = patch([t; flipud(t)], [Y_est+Yvar_est; flipud(Y_est-Yvar_est)], 'r');
for i=1:length(z)
    set(z(i),'FaceAlpha',0.3);
    set(z(i),'EdgeColor','None');
end
h = [];
h(1) = plot(Y_test_true,'-b');
h(2) = plot(Y_est,'-r');
title('Variance');
%ylim([0 2]);
legend(h,{'truth','prediction'},'Location','SE');

