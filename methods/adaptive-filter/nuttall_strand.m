function [ARF,RCF,RCB,PE] = nuttall_strand(Y, Pmax)
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
%  AR    multivariate autoregressive model parameter
%  RCF   forward reflection coefficients (= -PARCOR coefficients)
%  RCB   backward reflection coefficients (= -PARCOR coefficients)
%  PE    remaining error variances for increasing model order
%	   PE(:,p*M+[1:M]) is the residual variance for model order p
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
    delta = lyap(Rvv*inv(P(:,:,i)),inv(Pb(:,:,i))*Rww,-2*Rvw);
    
    TsqrtS = chol( P(:,:,i))'; %square root M defined by: M=Tsqrt(M)*Tsqrt(M)'
    TsqrtSb= chol(Pb(:,:,i))';
    pc(:,:,i+1) = inv(TsqrtS)*delta*inv(TsqrtSb)';
    
    %The forward and backward reflection coefficient
    K(:,:,i+1) = -TsqrtS *pc(:,:,i+1) *inv(TsqrtSb);
    Kb(:,:,i+1)= -TsqrtSb*pc(:,:,i+1)'*inv(TsqrtS);
    
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
    P(:,:,i+1)  = (I-TsqrtS *pc(:,:,i+1) *pc(:,:,i+1)'*inv(TsqrtS ))*P(:,:,i);
    Pb(:,:,i+1) = (I-TsqrtSb*pc(:,:,i+1)'*pc(:,:,i+1) *inv(TsqrtSb))*Pb(:,:,i);
end %for i = 1:Pmax,
R0 = PE(:,1:M);

%% [rcf,rcb,Pf,Pb] = pc2rcv(pc,R0);
rcf  = zeros(sz); rcf(:,:,1)  = I;
Pf   = zeros(sz); Pf(:,:,1)   = R0;
rcb  = zeros(sz); rcb(:,:,1) = I;
Pb   = zeros(sz); Pb(:,:,1)  = R0;

for p = 1:Pmax,
    TsqrtPf = chol( Pf(:,:,p))'; %square root M defined by: M=Tsqrt(M)*Tsqrt(M)'
    TsqrtPb= chol(Pb(:,:,p))';
    %reflection coefficients
    rcf(:,:,p+1) = -TsqrtPf *pc(:,:,p+1) *inv(TsqrtPb);
    rcb(:,:,p+1)= -TsqrtPb*pc(:,:,p+1)'*inv(TsqrtPf );
    %residual matrices
    Pf(:,:,p+1)  = (I-TsqrtPf *pc(:,:,p+1) *pc(:,:,p+1)'*inv(TsqrtPf ))*Pf(:,:,p);
    Pb(:,:,p+1) = (I-TsqrtPb*pc(:,:,p+1)'*pc(:,:,p+1) *inv(TsqrtPb))*Pb(:,:,p);
end %for p = 2:order,
%%%%%%%%%%%%%% end %%%%%%


%%%%% Convert reflection coefficients RC to autoregressive parameters
ARF = zeros(M,M*Pmax);
ARB = zeros(M,M*Pmax);
for K = 1:Pmax,
    ARF(:,K*M+(1-M:0)) = -rcf(:,:,K+1);
    ARB(:,K*M+(1-M:0)) = -rcb(:,:,K+1);
    for L = 1:K-1,
        tmp                    = ARF(:,L*M+(1-M:0)) - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
        ARF(:,L*M+(1-M:0))     = tmp;
    end;
end;
RCF = -reshape(rcf(:,:,2:end),[M,M*Pmax]);
% % transpose the matrix for each order of RCB coefs
% rcb_tran = permute(rcb,[2 1 3]);
RCB = -reshape(rcb(:,:,2:end),[M,M*Pmax]);
PE  = reshape(Pf,[M,M*(Pmax+1)]);
end