function LSPC_model=LSPC_train(x,y,sigma_chosen,lambda_chosen)
%
% Least-Squares Probabilistic Classification (training)
%
% Usage:
%       LSPC_model=LSPC_train(x,y,sigma_chosen,lambda_chosen)
%
% Input:
%    x : d by n training sample matrix
%    y : 1 by n training label vector (taking 1,...,c)
%    sigma_chosen (OPTIONAL) : Use the specified Gaussian width
%    lambda_chosen (OPTIONAL): Use the specified regularization parameter
%
% Output:
%    LSPC_model: learned model
%
% (c) Masashi Sugiyama, Department of Compter Science, Tokyo Institute of Technology, Japan.
%     sugi@cs.titech.ac.jp,     http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LSPC/

[d,n]=size(x);
c=max(y); % Number of classes
b=5000; % Maximum number of kernels

for yy=1:c
  tmp=x(:,y==yy);
  tmp_index=randperm(size(tmp,2));
  center(yy).index=tmp_index(1:min(b,size(tmp,2)));
  LSPC_model(yy).center=tmp(:,center(yy).index);
end
x2=x.^2;

if nargin<4 % cross-validation neeeded?
  sigma_list=[1/10 1/5 1/2 2/3 1 1.5 2 5 10]*sqrt(d); % Candidates of Gaussian width
  lambda_list=logspace(-2,0,9); % Candidates of regularization parameter
  score_cv=zeros(length(sigma_list),length(lambda_list));
  fold_cv=5;
  tmp=floor([0:n-1]*fold_cv./n)+1;
  cv_index=tmp(randperm(n));
  
% $$$ % Imlementation with pre-eigendecomposition (when length(lambda_list) is large)
% $$$   for sigma_index=1:length(sigma_list)
% $$$     sigma=sigma_list(sigma_index);
% $$$     for yy=1:c
% $$$       Kcvy=exp(-(repmat(sum(x2,1),[size(LSPC_model(yy).center,2) 1])...
% $$$                 +repmat(sum(LSPC_model(yy).center.^2,1)',[1 n])...
% $$$                 -2*LSPC_model(yy).center'*x)/(2*sigma^2));
% $$$       flag_tmp=cv_index(y==yy);
% $$$       for k=1:fold_cv
% $$$         flag=(flag_tmp(center(yy).index)~=k);
% $$$         [eigvec,eigval]=eig(Kcvy(flag,cv_index~=k)*Kcvy(flag,cv_index~=k)'/sum(cv_index~=k));
% $$$         tmp=eigvec'*(sum(Kcvy(flag,(y==yy) & (cv_index~=k)),2)/sum(cv_index~=k));
% $$$         for lambda_index=1:length(lambda_list)
% $$$           lambda=lambda_list(lambda_index);
% $$$           theta=eigvec*(1./(diag(eigval)+lambda).*tmp);
% $$$           ph(k,lambda_index).ph(yy,:)=theta'*Kcvy(flag,cv_index==k);
% $$$         end % for lambda_index
% $$$       end % for k
% $$$     end % for yy
% $$$     for k=1:fold_cv
% $$$       for lambda_index=1:length(lambda_list)
% $$$         [dummy,yh]=max(ph(k,lambda_index).ph); % Choose most probable class
% $$$         score_tmp(k,lambda_index)=mean(yh~=y(cv_index==k));
% $$$       end % for lambda_index
% $$$     end % for k
% $$$     score_cv(sigma_index,:)=mean(score_tmp);
% $$$   end % for sigma_index

  % Efficient implementation  
  for sigma_index=1:length(sigma_list)
    sigma=sigma_list(sigma_index);
    for yy=1:c
      Kcvy=exp(-(repmat(sum(x2,1),[size(LSPC_model(yy).center,2) 1])...
                +repmat(sum(LSPC_model(yy).center.^2,1)',[1 n])...
                -2*LSPC_model(yy).center'*x)/(2*sigma^2));
      flag_tmp=cv_index(y==yy);
      for k=1:fold_cv
        flag=(flag_tmp(center(yy).index)~=k);
        Hhcv0=Kcvy(flag,cv_index~=k)*Kcvy(flag,cv_index~=k)'/sum(cv_index~=k);
        hhcv=sum(Kcvy(flag,(y==yy) & (cv_index~=k)),2)/sum(cv_index~=k);
        for lambda_index=1:length(lambda_list)
          lambda=lambda_list(lambda_index);
          theta=(Hhcv0+lambda*eye(length(hhcv)))\hhcv;
          ph(k,lambda_index).ph(yy,:)=theta'*Kcvy(flag,cv_index==k);
        end % for lambda_index
      end % for k
    end % for yy
    for k=1:fold_cv
      for lambda_index=1:length(lambda_list)
        [dummy,yh]=max(ph(k,lambda_index).ph); % Choose most probable class
        score_tmp(k,lambda_index)=mean(yh~=y(cv_index==k));
      end % for lambda_index
    end % for k
    score_cv(sigma_index,:)=mean(score_tmp);
  end % for sigma_index

% $$$   % Simple implementation  
% $$$   tmp=repmat(sum(x2,1),[n 1]);
% $$$   x_dist2=tmp+tmp'-2*x'*x;
% $$$   for sigma_index=1:length(sigma_list)
% $$$     sigma=sigma_list(sigma_index);
% $$$     Kcv=exp(-x_dist2/(2*sigma^2));
% $$$     for lambda_index=1:length(lambda_list)
% $$$       lambda=lambda_list(lambda_index);
% $$$       for k=1:fold_cv
% $$$         clear ph
% $$$         for yy=1:c
% $$$           flag=((y==yy) & (cv_index~=k));
% $$$           Hhcv=Kcv(flag,cv_index~=k)*Kcv(flag,cv_index~=k)'/sum(cv_index~=k)...
% $$$                +lambda*eye(sum(flag));
% $$$           hhcv=sum(Kcv(flag,flag),2)/sum(cv_index~=k);
% $$$           theta=Hhcv\hhcv;
% $$$           ph(yy,:)=theta'*Kcv(flag,cv_index==k);
% $$$         end % for yy
% $$$         [dummy,yh]=max(ph); % Choose most probable class
% $$$         score_tmp(k)=mean(yh~=y(cv_index==k));
% $$$       end % for k
% $$$       score_cv(sigma_index,lambda_index)=mean(score_tmp);
% $$$     end % for lambda_index
% $$$   end % for sigma_index

  [score_cv_tmp,lambda_chosen_index]=min(score_cv,[],2);
  [score,sigma_chosen_index]=min(score_cv_tmp);
  lambda_chosen=lambda_list(lambda_chosen_index(sigma_chosen_index));
  sigma_chosen=sigma_list(sigma_chosen_index);
  
%  disp(sprintf('sigma = %g, lambda = %g',sigma_chosen,lambda_chosen))

end

LSPC_model(1).sigma_chosen=sigma_chosen;
for yy=1:c
  Ky=exp(-(repmat(sum(x2,1),[size(LSPC_model(yy).center,2) 1])...
           +repmat(sum(LSPC_model(yy).center.^2,1)',[1 n])...
           -2*LSPC_model(yy).center'*x)/(2*LSPC_model(1).sigma_chosen^2));
  Hhy=Ky*Ky'/n+lambda_chosen*eye(size(LSPC_model(yy).center,2));
  hhy=sum(Ky(:,y==yy),2)/n;
  LSPC_model(yy).coefficient=Hhy\hhy;
end
