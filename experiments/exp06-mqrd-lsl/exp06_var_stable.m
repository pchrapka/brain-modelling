%% exp06_var_stable
%
%   Goal: Generate a stable VAR(p) process
clear all;

K = 13;
p = 4;
samples = 500;
method = 'method2';

A = zeros(K,K,p);
Arow = [];
for i=1:p
    
    switch method
        case 'method1'
            %% Method 1
            % NOTE This works if p == 1
            % Generate random eigenvalues within unit circle
            lambda = zeros(K,1);
            keven = floor(K/2);
            kodd = K-2*keven;
            
            r = rand(keven,1);
            theta = 2*pi*rand(keven,1);
            x = r.*cos(theta);
            y = r.*sin(theta);
            
            lambda(1:keven,1) = x+1i*y;
            lambda(keven+1:2*keven,1) = x-1i*y;
            if kodd > 0
                lambda(end,1) = rand(1);
            end
            
            % Generate an orthonormal matrix
            Q = orth(rand(K,K));
            
            % Calculate the VAR parameters
            A(:,:,i) = Q*diag(lambda)*Q';
        case 'method2'
            % Source: http://www.kris-nimark.net/pdf/Handout_S1.pdf
            lambda = 2.5;
            A(:,:,i) = (lambda^(-i))*rand(K,K) - ((2*lambda)^(-i))*ones(K,K);
            
    end
    
    Arow = horzcat(Arow, A(:,:,i));
end

% Check
Afull = [Arow; eye(K*(p-1)) zeros(K*(p-1),K)];
if ~isequal(size(Afull),[K*p K*p])
    error('Afull has a bad size');
end

lambda = abs(eig(Afull))
if ~isempty(find(lambda > 1,1))
    fprintf('unstable VAR parameters\n');
    error('eigenvalues larger than 1');
else
    fprintf('stable VAR parameters\n');
end

%% 
K = 2;
p = 2;
A1 = [  0.5 0.1;...
        0.4 0.5];
A2 = [  0 0.2;...
        0.25 0];
Arow = [A1 A2];

% Check
Afull = [Arow; eye(K*(p-1)) zeros(K*(p-1),K)];
if ~isequal(size(Afull),[K*p K*p])
    error('Afull has a bad size');
end

lambda = abs(eig(Afull))
if ~isempty(find(lambda > 1,1))
    fprintf('unstable VAR parameters\n');
    error('eigenvalues larger than 1');
else
    fprintf('stable VAR parameters\n');
end