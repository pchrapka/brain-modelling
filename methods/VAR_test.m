%% VAR_test
close all;
clear all;

K = 4;
p = 2;
s = VAR(K,p);

s.coefs_gen();
disp(s.A);

s.coefs_check();

%% 
lambda = 0.5;
F = eye(K,K)*lambda^p;
for i=1:p
    Acoeff{i} = sym(sprintf('A%d',i),[K K]);
    F = F - Acoeff{i}*lambda^(p-1);
end
Fdet = det(F);
Fpoly = sym2poly(Fdet);
r = roots(Fpoly)

%% Simulate
nsamples = 10000;
[X,X_norm,~] = s.simulate(nsamples);

figure;
for i=1:K
    subplot(K,1,i);
    plot(X(i,:));
    if i==1
        title('X');
    end
end

figure;
for i=1:K
    subplot(K,1,i);
    plot(X_norm(i,:));
    if i==1
        title('X norm');
    end
end

%% Estimate AR params

% [AR,RC,PE] = lattice(X, p, 'BURG');  % treats each channel separately
clc;
[AR,RC,PE] = mvar(X', p, 13);
if ~isequal(size(AR),[K, K*p])
    fprintf('weird output size\n');
    disp(size(AR));
end
Aest = zeros(K,K,p);
for i=1:p
    idx_start = (i-1)*K+1;
    idx_end = i*K; 
    Aest(:,:,i) = AR(:,idx_start:idx_end);
    
    fprintf('Actual\n');
    disp(s.A(:,:,i));
    fprintf('Estimated\n');
    disp(Aest(:,:,i));
    
end
display(RC);