%% exp06_mqrdlsl_4channeldep_reflection
% 4 dependent channels
close all;

nsamples = 1000;
order = 2;
nchannels = 4;

% Kf = zeros(order, nchannels, nchannels);
% Kf = 0.2*ones(order, nchannels, nchannels);
% Kf = (1/4)*randn(order, nchannels, nchannels);
% Kf(1,:,:) = [...
% 	-0.8205         0       0.3         0;
%           0   -0.8205         0         0;
%         0.3         0   -0.8205         0;
%           0         0         0   -0.8205;...
%     ];
% Kf(2,:,:) = [...
%     0.9500         0         0         0;
%          0    0.9500         0         0;
%          0         0    0.9500         0;
%          0         0         0    0.9500;...
%     ];
Kf(1,:,:) = [...
	0.2       0.2       0.2       0.2;
      0       0.2       0.2       0.2;
      0         0       0.2       0.2;
      0         0         0       0.2;...
    ];
Kf(2,:,:) = [...
    0.2       0.2       0.2       0.2;
      0       0.2       0.2       0.2;
      0         0       0.2       0.2;
      0         0         0       0.2;...
    ];
Kb = Kf;

[~,X,noise] = gen_stationary_ar_lattice(Kf,Kb,nsamples);

% plot channels
figure;
for ch=1:nchannels
    subplot(nchannels,1,ch);
    plot(X(ch,:));
end

% estimate AR coefs
for ch=1:nchannels
    [a_est, e] = lpc(X(ch,:), order)
end

%% Estimate the Reflection coefficients using the QRD-LSL algorithm
i=1;
lattice = [];

% nchannels from above
% order from above
lambda = 0.99;
lattice(i).alg = MQRDLSL(nchannels,order,lambda);
lattice(i).scale = -1;
lattice(i).name = sprintf('MQRDLSL C%d P%d lambda=%0.2f',nchannels,order,lambda);
i = i+1;

% estimate the reflection coefficients
lattice = estimate_reflection_coefs(lattice, X);

%% Compare true and estimated
doplot = false;

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
    fprintf('order %d\n',p);
    fprintf('MSE Kf:\n');
    display(squeeze(Kfmse(p,:,:)));
    fprintf('MSE Kb:\n');
    display(squeeze(Kbmse(p,:,:)));
end