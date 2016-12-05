function pdc = pdc_alg_A(A, e_cov, nf, metric)
%function pdc = pdc_alg_A(A, e_cov, nf = 64, metric = 'euc'),
%     '''Generates spectral general (estatis. norm) PDC matrix from AR matrix
%
%       Input:
%         A(n, n, r) - recurrence matrix (n - number of signals, r - model order)
%         e_cov(n, n) - error covariance matrix
%         nf - frequency resolution
%
%       Output:
%         PDC(n, n, nf) - PDC matrix
%     '''

[n n r] = size(A);

switch lower(metric)
   case {'euc'}
      nornum = ones(n,1);
      norden = eye(n);
   case {'diag'}
      nornum = 1./diag(e_cov);
      norden = diag(1./diag(e_cov));
   case {'info'}
      nornum = 1./diag(e_cov);
      norden = inv(e_cov);
   otherwise
      error('Unknown metric.')
end;

Af = A_to_f(A, nf); % [ nf x n x n ]

nPDC=zeros(n,n);
dPDC=zeros(n);
dPDCa=zeros(n);
pdc=zeros(n,n,nf);

for ff = 1:nf,
   Aff=getAff(Af,ff);
   for kj=1:n,
      Affj=Aff(:,kj).*sqrt(nornum);
      pdc(:,kj,ff) = Affj./(sqrt(abs((Aff(:,kj)')*norden*Aff(:,kj))));
   end;
end;

function c = getAff(Af,ff)
%function c = getAff(C,ff)
% 
% Input:      C [NumChannel, NumChannel, nFreqs], either PDC,Lpatnaik
%               Lv2inf, Lv2sup
%             ff - ff-th frequency component of C
% Output:     c - A[ff,:,:] element

[Nfreq Nch Nch] = size(Af);
c=reshape(Af(ff,:,:), Nch,Nch);
