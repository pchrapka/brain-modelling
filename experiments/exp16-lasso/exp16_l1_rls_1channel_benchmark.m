%% exp16_l1_rls_1channel_benchmark
%
% Goal: Test the L1 RLS algorithms against each other

close all;

nsims = 20;%200;
nchannels = 1;
ntrials = 1;
nsamples = 200;

plot_mode = 'none';
verbosity = 0;

trace = cell(4,nsims);
a_true_sims = cell(nsims,1);

for j=1:nsims
    fprintf('sim: %d\n',j);
    
    count = 1;
    
    % a_coefs = [1 -1.6 0.95]';  % from Friedlander1982, case 1
    %coefs(1,1,:) = [0.7 0 0 -0.55 0 0];
    %norder = size(coefs,3);
    %
    % s = VAR(nchannels,norder);
    % s.coefs_set(coefs);
    % s.coefs_stable(true)
    
    %% generate sparse VAR process
    ncoefs = 3;
    norder = 30;
    sparsity = ncoefs/norder;
    
    s = VAR(nchannels,norder);
    s.coefs_gen_sparse('mode','exact','ncoefs',ncoefs_sparse,'stable',true,'verbose',1);
    disp(reshape(s.A,1,norder));
    
    % allocate mem for data
    x = zeros(nchannels,nsamples,ntrials);
    for i=1:ntrials
        [x(:,:,i),~,~] = s.simulate(nsamples);
    end
    
    %% Estimate the AR coefficients
    % x_all = x;
    %
    % order_est = norder;
    % [a_est, e] = lpc(x_all, order_est)
    
    %% Estimate the Reflection coefficients from the AR coefficients
    % [~,~,k_est] = rlevinson(a_est,e)
    
    %% Set plot params
    % coefs_true = shiftdim(coefs,2);
    % a_true = repmat(coefs_true,1,1,1,nsamples);
    % a_true = shiftdim(a_true,3);
    
    coefs_true = shiftdim(s.A,2);
    a_true = repmat(coefs_true,1,1,1,nsamples);
    a_true = shiftdim(a_true,3);
    a_true_sims{j} = a_true;
    
    % k_est_mat(:,1,1) = k_est;
    % k_true = repmat(-1*k_est_mat,1,1,1,nsamples);
    % k_true = shiftdim(k_true,3);
    
    %plot_options = {'ch1',1,'ch2',1,'true',a_true,'fields',{'x'}}
    plot_options = {'mode','3d','true',a_true,'fields',{'x'}};
    
    order_est = norder;
    
    %% Estimate the AR coefficients using RLS
    lambda = 0.99;
    filter = RLS(order_est,'lambda',lambda);
    trace{count,j} = LatticeTrace(filter,'fields',{'x'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
    %% Estimate the AR coefficients using L1_RRLS
    lambda = 0.99;
    gamma = 1.2;
    filter = L1_RRLS(order_est,'lambda',lambda,'gamma',gamma);
    trace{count,j} = LatticeTrace(filter,'fields',{'x'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
    %% Estimate the AR coefficients using OCD_TWL
    sigma = 10^(-1);
    lambda = sqrt(2*sigma^2*nsamples*log(norder));
    beta = 0.99;
    filter = OCD_TWL(order_est,lambda,beta);
    trace{count,j} = LatticeTrace(filter,'fields',{'x'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
    %% Estimate the AR coefficients using OSCD_TWL
    sigma = 10^(-1);
    lambda = sqrt(2*sigma^2*nsamples*log(norder));
    beta = 0.99;
    filter = OSCD_TWL(order_est,lambda,beta);
    trace{count,j} = LatticeTrace(filter,'fields',{'x'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
    
    %% Estimate the AR coefficients using OCCD_TWL
    sigma = 10^(-1);
    lambda = sqrt(2*sigma^2*nsamples*log(norder));
    beta = 0.99;
    filter = OCCD_TWL(order_est,lambda,beta);
    trace{count,j} = LatticeTrace(filter,'fields',{'x'});
    
    % run the filter
    if isequal(plot_mode,'plot')
        figure;
    end
    trace{count,j}.run(x,'verbosity',verbosity,'mode',plot_mode,...
        'plot_options',plot_options);
    
    count = count + 1;
end


%% Plot MSE
nfilters = size(trace,1);
estimate = cell(nfilters,nsims);
labels = cell(nfilters,1);
data_args = {};
for i=1:nfilters
    labels{i} = strrep(trace{i}.filter.name,'_',' ');
    for j=1:nsims
        estimate{i,j} = trace{i,j}.trace.x;
    end
    data_args = [data_args {estimate(i,:), a_true_sims}];
end

figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels);
save_fig_exp(mfilename('fullpath'),'tag','mse');

figure;
plot_mse_vs_iteration(...
    data_args{:},...
    'mode','log',...
    'labels',labels,...
    'normalized',true);
save_fig_exp(mfilename('fullpath'),'tag','nmse');