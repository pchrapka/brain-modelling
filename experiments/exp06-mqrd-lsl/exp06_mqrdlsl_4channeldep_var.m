%% exp06_mqrdlsl_4channeldep_var
% 4 dependent channels
%
%  Goal:
%  Test the MQRDLSL algorithm on a simulated signal that's explicitly
%  defined by a random stable VAR. The problem is made more difficult by
%  making the signals dependent on each other.

close all;
clc;

order = 2;
nchannels = 4;

s = VAR(nchannels, order);
s.coefs_gen();

%% Generate VAR

% Simulate long signal to get a good estimate of the true reflection
% coefficients, use lots of samples to get a good estimate of the truth
nsamples_long = 10000;
[~,Y,~] = s.simulate(nsamples_long);

% Use shorter signal length for adaptive algorithm
nsamples = 1000;
X = Y(:,1:nsamples);
    
% plot channels
figure;
for ch=1:nchannels
    subplot(nchannels,1,ch);
    plot(X(ch,:));
end

%% Esimate the Reflection coefficients using a stationary approach
% NOTE I have no way of generating a stable VAR process by specifying only
% reflection coefficients

% Estimate reflection coefs using mvar
[AR,RC,PE] = tsa.mvar(Y', order, 13);
Aest = zeros(nchannels,nchannels,order);
Kest_stationary = zeros(order,nchannels,nchannels);
% TODO change all 3-d arrays to K,K,p
for i=1:order
    idx_start = (i-1)*nchannels+1;
    idx_end = i*nchannels; 
    Aest(:,:,i) = AR(:,idx_start:idx_end);
    Kest_stationary(i,:,:) = RC(:,idx_start:idx_end);
    
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
%display(RC);

%% Estimate the Reflection coefficients using the QRD-LSL algorithm
i=1;
lattice = [];

% nchannels from above
% order from above
lambda = 0.99;
verbose = 1;
% lattice(i).alg = MQRDLSL1(nchannels,order,lambda);
lattice(i).alg = MQRDLSL2(nchannels,order,lambda);
lattice(i).scale = 1;
lattice(i).name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, X, verbose);

%% Compare true and estimated
doplot = true;

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

% mse
Kfmse = mse_coefs(lattice(1).scale*lattice(1).Kf, Kest_stationary, 'time');
Kbmse = mse_coefs(lattice(1).scale*lattice(1).Kb, Kest_stationary, 'time');
for p=1:order
    fprintf('order %d\n',p);
    fprintf('MSE Kf:\n');
    display(squeeze(Kfmse(p,:,:)));
    fprintf('MSE Kb:\n');
    display(squeeze(Kbmse(p,:,:)));
end