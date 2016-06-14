function px=pdf_Gaussian(x,mu,sigma)
  
  [d,n]=size(x);

  tmp=(x-repmat(mu,[1 n]))./repmat(sigma,[1 n])/sqrt(2);
  px=(2*pi)^(-d/2)/prod(sigma)*exp(-sum(tmp.^2,1));
