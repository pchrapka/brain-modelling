function [RCF,RCB,FE] = nuttall_strand_rc(Y, Pmax)
% NUTTALLSTRAND estimates parameters of the Multi-Variate AutoRegressive model 
%   Mode 13 from tsa.mvar
%
%    Y(t) = Y(t-1) * A1 + ... + Y(t-p) * Ap + X(t);  
% whereas
%    Y(t) is a row vecter with M elements Y(t) = y(t,1:M) 
%
% 	[AR,RCF,RCB,PE] = mvar(Y, p);
% 
% with 
%       AR = [A1, ..., Ap];
%
% INPUT:
%  Y	 Multivariate data series 
%  p     Model order
%  Mode	 determines estimation algorithm 
%
% OUTPUT:
%  RCF   forward reflection coefficients (= -PARCOR coefficients)
%  RCB   backward reflection coefficients (= -PARCOR coefficients)
%  FE    remaining forward error variances for increasing model order
%	   FE(:,p*M+[1:M]) is the residual variance for model order p
%

% this is equivalent to Mode==11 but can deal with missing values
%%%%%%%%%%% [pc,R0] = burgv_nan(reshape(Y',[M,1,N]),Pmax,1);
% Copyright S. de Waele, March 2003 - modified Alois Schloegl, 2009

import tsa.*

% Inititialization
[N,M,T] = size(Y); % [samples, channels,trials]

if nargin<2, 
        Pmax=max([N,M])-1;
end;

if iscell(Y)
        Pmax = min(max(N ,M ),Pmax);
        C    = Y;
end;
if T > 1
    Ytemp = permute(Y,[2 1 3]);
    Ytemp = reshape(Ytemp,[M, N*T]);
    [C(:,1:M),n] = covm(Ytemp','M');
    clear Ytemp
else
    [C(:,1:M),n] = covm(Y,'M');
end
PE(:,1:M)  = C(:,1:M)./n;


I = eye(M);

sz = [M,M,Pmax+1];
pc= zeros(sz); pc(:,:,1) =I;
K = zeros(sz); K(:,:,1)  =I;
Kb= zeros(sz); Kb(:,:,1) =I;
P = zeros(sz);
Pb= zeros(sz);

%[P(:,:,1)]= covm(Y);
[P(:,:,1)]= PE(:,1:M);	% normalized
Pb(:,:,1)= P(:,:,1);
f = Y;
b = Y;

debug = false;
debug_plot = false;
% debug = true;
% debug_plot = true;

%the recursive algorithm
for i = 1:Pmax,
    v = f(2:end,:,:);
    w = b(1:end-1,:,:);
    
    %% normalized, unbiased
    Rvv = zeros(M);
    Rww = zeros(M);
    Rvw = zeros(M);
    Rwv = zeros(M);
    for t = 1:T
        vt = squeeze(v(:,:,t));
        wt = squeeze(w(:,:,t));
        Rvv = Rvv + covm(vt); %Pfhat
        Rww = Rww + covm(wt); %Pbhat
        Rvw = Rvw + covm(vt,wt); %Pfbhat
        Rwv = Rwv + covm(wt,vt); % = Rvw', written out for symmetry
    end
    %delta = lyap(Rvv*inv(P(:,:,i)),inv(Pb(:,:,i))*Rww,-2*Rvw);
    delta = lyap(Rvv/P(:,:,i),Pb(:,:,i)\Rww,-2*Rvw);
    
    TsqrtS = chol( P(:,:,i))'; %square root M defined by: M=Tsqrt(M)*Tsqrt(M)'
    TsqrtSb= chol(Pb(:,:,i))';
    %pc(:,:,i+1) = inv(TsqrtS)*delta*inv(TsqrtSb)';
    pc(:,:,i+1) = (TsqrtS\delta)/(TsqrtSb');
    
    %The forward and backward reflection coefficient
    %K(:,:,i+1) = -TsqrtS *pc(:,:,i+1) *inv(TsqrtSb);
    K(:,:,i+1) = -TsqrtS *pc(:,:,i+1) /TsqrtSb;
    %Kb(:,:,i+1)= -TsqrtSb*pc(:,:,i+1)'*inv(TsqrtS);
    Kb(:,:,i+1)= -TsqrtSb*pc(:,:,i+1)'/TsqrtS;
    
    %filtering the reflection coefficient out:
    f = zeros(size(vt));
    b = zeros(size(vt));
    for t = 1:T
        vt = squeeze(v(:,:,t));
        wt = squeeze(w(:,:,t));
        f(:,:,t) = (vt'+ K(:,:,i+1)*wt')';
        b(:,:,t) = (wt'+Kb(:,:,i+1)*vt')';
    end
    
    %The new R and Rb:
    %residual matrices
    %P(:,:,i+1)  = (I-TsqrtS *pc(:,:,i+1) *pc(:,:,i+1)'*inv(TsqrtS ))*P(:,:,i);
    P(:,:,i+1)  = (I-TsqrtS *pc(:,:,i+1) *pc(:,:,i+1)'/TsqrtS )*P(:,:,i);
    %Pb(:,:,i+1) = (I-TsqrtSb*pc(:,:,i+1)'*pc(:,:,i+1) *inv(TsqrtSb))*Pb(:,:,i);
    Pb(:,:,i+1) = (I-TsqrtSb*pc(:,:,i+1)'*pc(:,:,i+1) /TsqrtSb)*Pb(:,:,i);
    
    if debug
        fprintf('order %d\n',i);
        process = VRC(M,i);
        process.coefs_set(permute(K(:,:,2:i+1),[3 1 2]),permute(Kb(:,:,2:i+1),[3 1 2]));
        process.coefs_stable(true,'method','ar');
        process.coefs_stable(true,'method','sim');
        if debug_plot
            figure;
            [x,~,~] = process.simulate(3000,'sigma',max(diag(P(:,:,i+1))));
            plot(x');
            title(sprintf('order %d',i));
        end
        disp(K(:,:,i+1));
    end
end %for i = 1:Pmax,

RCF = reshape(K(:,:,2:end),[M,M*Pmax]);
% % transpose the matrix for each order of RCB coefs
% rcb_tran = permute(rcb,[2 1 3]);
RCB = reshape(Kb(:,:,2:end),[M,M*Pmax]);
FE  = reshape(P,[M,M*(Pmax+1)]);
end