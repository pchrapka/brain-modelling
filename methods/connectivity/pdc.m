function c=pdc(A,pf,varargin)

%Compute connectivity measure given by "option" from series j-->i.
%
%function c=pdc(A,pf,...)
%
%   Input
%   -----
%   A
%       AR estimate matrix by MVAR
%   pf
%       covariance matrix provided by MVAR
%
%   Parameters
%   ----------
%   nFreqs (integer, default = 128)
%       number of point in [0,fs/2] frequency scale
%   metric
%       euc  - Euclidean ==> original PDC
%       diag - diagonal ==> gPDC (generalized )
%       info - Information ==> iPDC
%
%   Output
%   ------
%   c.pdc       - |PDC|^2 estimates
%   c.pvalues   - p-values associated to pdc estimates. 
%   c.th        - Threshold value with (1-avalue) significance level.
%   c.ic1,c.ic2 -  confidence interval
%   c.metric    - metric for PDC calculation
%   c.alpha     - significance level
%   c.p         - VAR model order
%   c.patdenr   - 
%   c.patdfr    - degree of freedom 
%
%   Modified from asymp_pdc

%Corrected 7/25/2011 to match the frequency range with plotting
%routine, f = 0 was include in the frequency for loop:
%                                for ff = 1:nFreqs,
%                                   f = (ff-1)/(2*nFreqs); % 
%                                        ^?^^

pmain = inputParser();
addParameter(pmain,'metric','euc',@(x) any(validatestring(x,{'euc','diag','info'})));
addParameter(pmain,'nFreqs',128,@isnumeric);
parse(pmain,varargin{:});

nFreqs = pmain.Results.nFreqs;
metric = pmain.Results.metric;

% [m,n]=size(x);
% if m > n,
%    x=x.';
% end;
% np = length(x);
[nChannels,n0,p] = size(A);
Af = A_to_f(A, nFreqs);

% Variables initialization
pdc_result = zeros(nChannels,nChannels,nFreqs);
disp('----------------------------------------------------------------------');
switch lower(metric)
    case {'euc'}
        disp('                       Original PDC estimation')
    case {'diag'}
        disp('                      Generalized PDC estimation')
    case {'info'}
        disp('                     Information PDC estimation')
    otherwise
        error('Unknown metric.')
end;
disp('======================================================================');

% gamma = bigautocorr(x, p);
% omega = kron(inv(gamma), pf);
% omega_evar = 2*pinv(Dup(nChannels))*kron(pf, pf)*pinv(Dup(nChannels)).';

for ff = 1:nFreqs,
   %f = (ff-1)/(2*nFreqs); %Corrected 7/25/2011, f starting at 0 rad/s.
   %Ca = fCa(f, p, nChannels);
   %omega2 = Ca*omega*Ca';
   %L = fChol(omega2);

   a = Af(ff,:,:); a=a(:);    %Equivalent to a = vec(Af[ff, :, :])
   a = [real(a); imag(a)];    %a = cat(a.real, a.imag, 0)

   for i = 1:nChannels,
      for j = 1:nChannels,

         Iij = fIij(i, j, nChannels);
         Ij = fIj(j, nChannels);
         %For diag or info case, include evar in the expression'
         switch lower(metric)
            case {'euc'}
               Iije = Iij;
               Ije = Ij;
               
            case {'diag'}
               evar_d = mdiag(pf);
               evar_d_big = kron(eye(2*nChannels), evar_d);
               Iije = Iij*pinv(evar_d_big);
               Ije = Ij*pinv(evar_d_big);

            case {'info'}
               evar_d = mdiag(pf);
               evar_d_big = kron(eye(2*nChannels), evar_d);
               Iije = Iij*pinv(evar_d_big);

               evar_big = kron(eye(2*nChannels), pf);
               Ije = Ij*pinv(evar_big)*Ij;
               
            otherwise
               error('Unknown metric.')
         end;

         num = a.'*Iije*a;
         den = a.'*Ije*a;
         pdc_result(i, j, ff) = num/den;
         % If alpha == 0, do not calculate statistics for faster PDC
         % computation.
      end;
   end;
end;

c.pdc=pdc_result;
c.metric=metric;
c.alpha=0;
c.p=p;
c.pvalues = [];
c.th=[];
c.ic1=[];
c.ic2=[];
c.patdenr = [];
c.patdfr = [];
c.varass1 = [];
c.varass2 = [];

%==========================================================================
% function gamma = bigautocorr(x, p)
% %Autocorrelation. Data in rows. From order 0 to p-1.
% %Output: nxn blocks of autocorr of lags i. (Nuttall Strand matrix)'''
% [n, nd] = size(x);
% 
% gamma = zeros(n*p, n*p);
% for i = 1:p
%    for j = 1:p
%       gamma(((i-1)*n+1):i*n, ((j-1)*n+1):j*n) = xlag(x, i-1)*(xlag(x,j-1).')/nd;
%    end;
% end;

%==========================================================================
% function c= xlag(x,tlag)
% if tlag == 0,
%    c=x;
% else
%    c = zeros(size(x));
%    c(:,(tlag+1):end) = x(:,1:(end-tlag));
% end;

%==========================================================================
% function d = fEig(L, G2)
% %'''Returns the eigenvalues'''
% 
% %L = mat(cholesky(omega, lower=1))
% D = L.'*G2*L;
% %    d = eigh(D, eigvals_only=True)
% %disp('fEig: eig or svd?')
% d = svd(D);
% d1=sort(d);
% %
% % the two biggest eigenvalues no matter which values (non negative by
% % construction
% %
% d=d1(length(d)-1:length(d));
% 
% if (size(d) > 2),
%    disp('more than two Chi-squares in the sum:')
% end;

%==========================================================================
function c = fIij(i, j, n)
%'''Returns Iij of the formula'''
Iij = zeros(1,n^2);
Iij(n*(j-1)+i) = 1;
Iij = diag(Iij);
c = kron(eye(2), Iij);

%==========================================================================
function c=  fIj(j, n)
%'''Returns Ij of the formula'''
Ij = zeros(1,n);
Ij(j) = 1;
Ij = diag(Ij);
Ij = kron(Ij, eye(n));
c = kron(eye(2), Ij);

%==========================================================================
% function d = fCa(f, p, n)
% %'''Returns C* of the formula'''
% C1 = cos(-2*pi*f*(1:p));
% S1 = sin(-2*pi*f*(1:p));
% C2 = [C1; S1];
% d = kron(C2, eye(n^2));

%==========================================================================
% function c = fdebig_de(n)
% %'''Derivative of kron(I(2n), A) by A'''
% %c = kron(TT(2*n, n), eye(n*2*n)) * kron(eye(n), kron(vec(eye(2*n)), eye(n)));
% A=sparse(kron(TT(2*n, n), eye(n*2*n)));
% B=sparse(kron(vec(eye(2*n)), eye(n)));
% c = A * kron(eye(n), B);
% c=sparse(c);

%==========================================================================
% function c = vec(x)
% %vec = lambda x: mat(x.ravel('F')).T
% c=x(:);

%==========================================================================
% function t = TT(a,b)
% %''' TT(a,b)*vec(B) = vec(B.T), where B is (a x b).'''
% t = zeros(a*b);
% for i = 1:a,
%    for j =1:b,
%       t((i-1)*b+j, (j-1)*a+i) = 1;
%    end;
% end;
% t = sparse(t);
%==========================================================================
% function L = fChol(omega)
% % Try Cholesky factorization
% try,
%    L = chol(omega)';
%    % If there's a small negative eigenvalue, diagonalize
% catch,
%    %   disp('linalgerror, probably IP = 1.')
%    [v,d] = eig(omega);
%    L = zeros(size(v));
%    for i =1:length(d),
%       if d(i,i)<0,
%          d(i,i)=eps;
%       end;
%       L(:,i) = v(:,i)*sqrt(d(i,i));
%    end;
% end;

%==========================================================================
% function c = diagtom(a)
% a=sparse(a');
% c=sparse(diag(a(:)));

%==========================================================================
function c = mdiag(a)
%  diagonal matrix
c=diag(diag(a));

%==========================================================================
% function d=Dup(n)
% %     '''D*vech(A) = vec(A), with symmetric A'''
% d = zeros(n*n, (n*(n+1))/2);
% count = 1;
% for j=1:n,
%    for i =1:n,
%       if i >= j,
%          d((j-1)*n+i, count)=1;
%          count = count+1;
%       else
%          d((j-1)*n+i,:)=d((i-1)*n+j,:);
%       end;
%    end;
% end;

%==========================================================================

