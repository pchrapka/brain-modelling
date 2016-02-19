%% exp06_mqrdlsl_4channeldep_reflection
% 4 dependent channels
%
%  Goal:
%  Test the MQRDLSL algorithm on a simulated signal that's explicitly
%  defined by the reflection coefficients. The problem is made more
%  difficult by making the signals dependent on each other.

close all;

nsamples = 1000;
order = 2;
nchannels = 4;

version_coefs = 1;
switch version_coefs
    case 1
        Kf = 0.082*ones(order, nchannels, nchannels);
        % Note a multiple of 0.1 is too big for the algo
    case 2
        % Good signal
        % Bad algo results
        Kf = (1/4)*randn(order, nchannels, nchannels);
    case 3
        Kf(1,:,:) = [...
            -0.8205         0       0.3         0;
            0   -0.8205         0         0;
            -0.3         0   -0.8205         0;
            0         0         0   -0.8205;...
            ];
        Kf(2,:,:) = [...
            0.9500         0         0         0;
            0    0.9500         0         0;
            0         0    0.9500         0;
            0         0         0    0.9500;...
            ];
    case 4
        U(1,:,:) = [...
        	  1         1         1         1;
              0         1         1         1;
              0         0         1         1;
              0         0         0         1;...
            ];
        U(2,:,:) = [...
              1         1         1         1;
              0         1         1         1;
              0         0         1         1;
              0         0         0         1;...
            ];
        multiple = 0.1;
        % Note a multiple of 0.2 is too big for the algo
        Kf = multiple*U;
    otherwise
        error('unknown version %s\n',version_coefs);
end
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
lattice(i).alg = MQRDLSL1(nchannels,order,lambda);
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