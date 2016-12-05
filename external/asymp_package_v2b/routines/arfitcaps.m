%% ARFITCAPS is capsule to call the arfit.m routine, part of "ARfit: Multivariate
%% Autoregressive Model Fitting" package, which implements algorithms as described 
%% in the following papers:
%% 1. A. Neumaier and T. Schneider, 2001: Estimation of parameters and
%%    eigenmodes of multivariate autoregressive models. ACM Trans. Math.
%%    Softw., 27, 27-57.
%% 2. T. Schneider and A. Neumaier, 2001: Algorithm 808: ARfit - A Matlab
%%      package for the estimation of parameters and eigenmodes of multivariate
%%      autoregressive models. ACM Trans. Math. Softw., 27, 58-65. 
%
%%  If you are interested in using ARfit algorithm for VAR model estimation, 
%%  we advice you to get the software from Tapio Schneider's website at
%%                http://www.gps.caltech.edu/~tapio/arfit/index.html
%%  and before using verify the license term, it seems that it is a 
%%  copyrighted material by the Association for Computing Machinery, Inc.
%%
%%  Note: As describe by the authors, acf.m in ARfit needs Signal Processing 
%%  Toolbox, as it requires XCORR, a cross-correlation function estimator.

%%  Availability checked on February 24, 2011. KS

function [pf,A,ef]=arfitcaps(u,IP)

if ~exist('arfits.m','file')
   help arfitcaps
   error('ARfit.m not found.')
end;

v=u';
[w, Au, C, sbc, fpe, th]=arfit(v,IP,IP);
pf=C;

if IP >= 20
   [siglev,res]=arres(w,Au,v,IP+1);
else
   [siglev,res]=arres(w,Au,v);
end;

ef=res';
siglev; % Not used
A=zeros(length(w),length(w),IP);
for i=1:IP
   A(:,:,i)=Au(:,(i-1)*length(w)+1:i*length(w));
   wu=ceil(length(ef)*rand(size(w)));
   if length(ef)<length(v)
      ef=[ef ef(:,wu(1))];
   else
      ef=ef(:,1:length(v));
   end
end
