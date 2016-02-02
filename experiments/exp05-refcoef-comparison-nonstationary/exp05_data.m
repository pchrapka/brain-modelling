%% exp05_data

nsamples_per_segment = 1000;
noise = randn(nsamples_per_segment,1);

i=1;

piecewise(i).a = [1 -1.6 0.95];
piecewise(i).x = filter(1,piecewise(i).a,noise); % from Friedlander1982, case 1

% normalize x to unit variance
piecewise(i).x = piecewise(i).x/std(piecewise(i).x);
disp(var(piecewise(i).x/std(piecewise(i).x))) % should be 1

i=i+1;

% piecewise(i).a = [1 -0.5 0.5]; % medium change
piecewise(i).a = [1 -0.1 0.1]; % large change
% piecewise(i).a = [1 -1.3 0.8]; % small change in reflection coefs
piecewise(i).x = filter(1,piecewise(i).a,noise); % from Friedlander1982, case 1

% normalize x to unit variance
piecewise(i).x = piecewise(i).x/std(piecewise(i).x);
disp(var(piecewise(i).x/std(piecewise(i).x))) % should be 1

nsegments = length(piecewise);

%% Estimate the AR coefficients and reflection coefficients
M = 2;
x = [];
k_true = [];
for i=1:nsegments
    fprintf('segment %d\n',i);
    % Estimate the AR coefficients
    [piecewise(i).a_est, piecewise(i).e] = lpc(piecewise(i).x, M);
    fprintf('\tAR coefs\n');
    disp(piecewise(i).a_est);

    % Estimate the Reflection coefficients from the AR coefficients
    [~,~,piecewise(i).k_est] = rlevinson(piecewise(i).a_est, piecewise(i).e);
    fprintf('\tReflection coefs\n');
    disp(piecewise(i).k_est);
    
    % Combine the segments
    x = [x; piecewise(i).x];
    k_true = [k_true repmat(piecewise(i).k_est,1,nsamples_per_segment)];
end

figure;
plot(x)

nsamples = length(x);