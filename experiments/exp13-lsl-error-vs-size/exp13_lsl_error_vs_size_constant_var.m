%% exp13_lsl_error_vs_size_constant_var
%   Goal:
%   Test error of MQRDLSL algorithm as a function of number of parameters.
%   Here we keep that VAR process order constant

var_order = 5;

order = [2,4,6,8,10];
channels = [2,4,6,8,10,12,14];

norder = length(order);
nchannels = length(channels);

% allocate mem
results = [];
results.ms_inno_error = zeros(nchannels,norder);
results.ms_inno_error_ch = zeros(nchannels,norder);
results.rev = zeros(nchannels,norder);
results.rev_ch = zeros(nchannels,norder);
ch_save = 1; % channel to save
for i=1:nchannels
    for j=1:norder
        
        %% generate VAR
        s = VAR(channels(i), var_order);
        s.coefs_gen();
        
        % simulate data
        nsamples = 1000;
        [X,X_norm,noise] = s.simulate(nsamples);
        
        %% Estimate coefs using lattice filter
        
        % channels from above
        % order from above
        lambda = 0.99;
        filter = MQRDLSL2(channels(i),order(j),lambda);
        trace = LatticeTrace(filter,'fields',{'Kf','ferror'});
        
        % run the filter
        trace.run(X,'verbosity',0);
        
        %% Calculate the relative error
        % Section 3.3 in Schlogl2000
        
        % innovation error Lewis1990
        inno_error = (trace.trace.ferror(:,:,end)' - noise).^2;
        ms_inno_error = sum(inno_error(:))/numel(inno_error);
        
        % per channel
        ms_inno_error_ch = sum(inno_error,2)/size(inno_error,2);
        
        % relative error variance
        % section 3.3 in Schlogl2000
        ms_signal = var(X(:));
        % all iterations, all channels, last order
        last_ferror = trace.trace.ferror(:,:,end);
        ms_pred_error = var(last_ferror(:));
        rev = ms_pred_error/ms_signal;
        
        % per channel
        ms_signal_ch = var(X,0,2);
        ms_pred_error_ch = var(last_ferror,0,1)';
        rev_ch = ms_pred_error_ch./ms_signal_ch;
        
        % save results
        results.ms_inno_error(i,j) = ms_inno_error;
        results.ms_inno_error_ch(i,j) = ms_inno_error_ch(ch_save);
        results.rev(i,j) = rev;
        results.rev_ch(i,j) = rev_ch(ch_save);
    end
    
end

%% Plots
x = repmat(channels',1,norder);
y = repmat(order,nchannels,1);
figure;
surf(x,y,results.rev);
title('Relative Error Variance');
zlabel('REV');
xlabel('Channels');
ylabel('Order');

figure;
surf(x,y,results.ms_inno_error);
title('Innovation Error');
zlabel('MSE');
xlabel('Channels');
ylabel('Order');

x = repmat(channels',1,norder);
y = repmat(order,nchannels,1);
figure;
surf(x,y,results.rev_ch);
title(sprintf('Relative Error Variance - Channel %d',ch_save));
zlabel('REV');
xlabel('Channels');
ylabel('Order');

figure;
surf(x,y,results.ms_inno_error_ch);
title(sprintf('Innovation Error - Channel %d',ch_save));
zlabel('MSE');
xlabel('Channels');
ylabel('Order');