function [yh,ph]=LSPC_test(xtest,LSPC_model)
%
% Least-Squares Probabilistic Classification (test)
%
% Usage:
%       [yh,ph]=LSPC_test(xtest,LSPC_model)
%
% Input:
%    xtest : d by ntest test sample matrix
%    LSPC_model:  LSPC_model (obtained by LSPC_train.m)
%
% Output:
%    yh: (1 by ntest) vector consisting of predicted classes
%    ph: (c by ntest) matrix consisting of class-posterior probabilities
%
% (c) Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     sugi@cs.titech.ac.jp,     http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LSPC/

  c=length(LSPC_model); % Number of classes
  ntest=size(xtest,2);
  ph=zeros(c,ntest);   % Class-posterior probabilities
  for yy=1:c
    Ktesty=exp(-(repmat(sum(xtest.^2,1),[size(LSPC_model(yy).center,2) 1])...
               +repmat(sum(LSPC_model(yy).center.^2,1)',[1 ntest])...
               -2*LSPC_model(yy).center'*xtest)/(2*LSPC_model(1).sigma_chosen^2));
    ph(yy,:)=max(0,LSPC_model(yy).coefficient'*Ktesty);
  end
  ph=ph./repmat(sum(ph,1),[c 1]); % Normalization
  [ph_max,yh]=max(ph); % Choose most probable class
