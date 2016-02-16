%% exp06_mqrdlsl_4channeldep
% 4 dependent channels
close all;

nsamples = 1000;
order = 2;
nchannels = 4;
% %a_coefs = [1 0.082*ones(1,order)];  % from Lewis1990
% r_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
% A = zeros(order+1, nchannels, nchannels);
% for ch=1:nchannels
%     A(:,ch,ch) = a_coefs;
% end
% [~,X] = gen_stationary_ar(A,nsamples);
Kf = zeros(order,nchannels, nchannels);
Kf(1,:,:) = [...
	-0.8205         0         0         0;
          0   -0.8205         0         0;
          0         0   -0.8205         0;
          0         0         0   -0.8205;...
    ];
Kf(2,:,:) = [...
    0.9500         0         0         0;
         0    0.9500         0         0;
         0         0    0.9500         0;
         0         0         0    0.9500;...
    ];
Kb = Kf;
% noise = randn(nchannels, nsamples);
% X = rlattice_allpole_allpass(Kf,Kb,noise);
% 
% % NOTE Normalizing the variance is actually incredibly important to get
% % sensible results
% 
% % normalize the variance
% X = X./repmat(std(X,0,2),1,nsamples);

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

for ch=1:nchannels
    figure;
    k_true = repmat(squeeze(Kf(:,ch,ch)),1,nsamples);
    plot_reflection_coefs(lattice, k_true, nsamples, ch, ch);
end