%% exp13_lsl_error_vs_size
%   Goal:
%   Test error of MQRDLSL algorithm as a function of number of parameters

order = [2,4,6,8,10];
channels = [2,4,6,8,10,12,14];

norder = length(order);
nchannels = length(channels);

% allocate mem
results = [];
results.ms_inno_error = zeros(nchannels,norder);
results.rev = zeros(nchannels,norder);
for i=1:nchannels
    for j=1:norder
        
        %% generate VAR
        s = VAR(channels(i), order(j));
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
        
        % relative error variance
        % section 3.3 in Schlogl2000
        ms_signal = var(X(:));
        % all iterations, all channels, last order
        last_ferror = trace.trace.ferror(:,:,end);
        ms_pred_error = var(last_ferror(:));
        rev = ms_pred_error/ms_signal;
        
        % save results
        results.ms_inno_error(i,j) = ms_inno_error;
        results.rev(i,j) = rev;
    end
    
end

%% Plots
figure;
surf(results.rev);
title('Relative Error Variance');
zlabel('REV');
xlabel('Number of channels');
ylabel('Order');
% FIXME This is showing a strange pattern, decreasing for increasing
% channel number

figure;
surf(results.ms_inno_error);
title('Innovation Error');
zlabel('MSE');
xlabel('Number of channels');
ylabel('Order');