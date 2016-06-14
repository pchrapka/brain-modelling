% demo_LSPC.m
%
% Least-Squares Probabilistic Classification
%
% (c) Masashi Sugiyama, Department of Compter Science,
%     Tokyo Institute of Technology, Japan.
% sugi@cs.titech.ac.jp
% http://sugiyama-www.cs.titech.ac.jp/~sugi/software/LSPC/

clear all

rand('state',0);
randn('state',0);

%print_type='epsc';
print_type='png';

%%%%%%%%%%%%%%%%%%%%%%%%% Generating data
n=200; % The number of training samples
c=3;   % The number of classes (y=1,...,c)
class_prior=[1/4 1/4 1/2]; % Class-prior probabilities p(y)

%Generating multinomial random variables
tmp=rand(1,n); 
for y=1:c 
  ny(y)=sum(tmp>sum(class_prior(1:y-1)) & tmp<sum(class_prior(1:y)));
end

%Generating training samples
n3a=sum(rand(1,ny(3))>0.5);
n3b=ny(3)-n3a;
x=[randn(2,ny(1))-2*[ones(1,ny(1));zeros(1,ny(1))] ...
   randn(2,ny(2))+2*[ones(1,ny(2));zeros(1,ny(2))] ...
   [2*randn(1,n3a);randn(1,n3a)]-3*[zeros(1,n3a);ones(1,n3a)] ...
   [randn(1,n3b);2*randn(1,n3b)]+2*[zeros(1,n3b);ones(1,n3b)]];
y=[ones(1,ny(1)) 2*ones(1,ny(2)) 3*ones(1,ny(3))];

%Generating test samples
x1disp=linspace(-10,10,30);
x2disp=linspace(-10,10,30);
xtest1=repmat(x1disp',[1 length(x2disp)]);
xtest2=repmat(x2disp,[length(x1disp) 1]);
xtest=[xtest1(:)';xtest2(:)'];
ntest=size(xtest,2);

%Computing class probability densities p(x=xtest|y) for each y
class_pdf(1,:)=pdf_Gaussian(xtest,[-2; 0],[1;1]);
class_pdf(2,:)=pdf_Gaussian(xtest,[ 2; 0],[1;1]);
class_pdf(3,:)=pdf_Gaussian(xtest,[ 0;-3],[2;1])/2 ...
              +pdf_Gaussian(xtest,[ 0; 2],[1;2])/2;

%Computing class-posterior probabilities p(y|x=xtest) for each y and 
class_posterior=class_pdf.*repmat(class_prior',[1 ntest]); %p(y|xtest)
class_posterior=class_posterior./repmat(sum(class_posterior,1),[3 1]);

%True labels of test samples
[dummy ytest]=max(class_posterior,[],1); 

%Normalizing data to have mean zero and unit variance
x_std=std(x,0,2);
x_mean=mean(x,2);
x_normalized=(x-repmat(x_mean,[1 n]))./repmat(x_std,[1 n]);
xtest_normalized=(xtest-repmat(x_mean,[1 ntest]))./repmat(x_std,[1 ntest]);


%%%%%%%%%%%%%%%%%%%%%%%%% Estimating class-posterior probability

tic

LSPC_model=LSPC_train(x_normalized,y);
[ytest_LSPC,class_posterior_LSPC]...
    =LSPC_test(xtest_normalized,LSPC_model);

toc

%%%%%%%%%%%%%%%%%%%%%%%%% Plotting results
COLOR={'r','b','g'};
SYMBOL={'^','v','s'};

%Training samples and optimally labeled test samples
figure(1), clf, hold on
set(gca,'FontName','Helvetica','FontSize',8)
title('Training and optimally labeled test samples')
for yy=1:c
  plot(x(1,y==yy),x(2,y==yy),...
       [COLOR{yy} SYMBOL{yy}],'LineWidth',0.5,'MarkerSize',6,...
       'MarkerFaceColor',COLOR{yy});
  plot(xtest(1,ytest==yy),xtest(2,ytest==yy),...
       [COLOR{yy} SYMBOL{yy}],'LineWidth',0.5,'MarkerSize',3);
  LEGEND{2*yy-1}=sprintf('Training (y=%g)',yy);
  LEGEND{2*yy}=sprintf('Test (y=%g)',yy);
end
axis([min(x1disp) max(x1disp) min(x2disp) max(x2disp)])
legend(LEGEND,4)
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 12 9]);
print(['-d' print_type],'OPTsample')

%Training samples and LSPC-labeled test samples
figure(2), clf, hold on
set(gca,'FontName','Helvetica','FontSize',8)
title('Training and LSPC-labeled test samples')
for yy=1:c
  plot(x(1,y==yy),x(2,y==yy),[COLOR{yy} SYMBOL{yy}],...
       'LineWidth',0.5,'MarkerSize',6,'MarkerFaceColor',COLOR{yy});
  plot(xtest(1,yy==ytest_LSPC),xtest(2,yy==ytest_LSPC),[COLOR{yy} SYMBOL{yy}],...
       'LineWidth',0.5,'MarkerSize',3);
end
axis([min(x1disp) max(x1disp) min(x2disp) max(x2disp)])
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0 12 9]);
print(['-d' print_type],'LSPCsample')

%True class probability density functions
for yy=1:c
  figure(100+yy), clf, hold on
  set(gca,'FontName','Helvetica','FontSize',10)
  title(sprintf('True class probability densities p(x|y=%g)',yy))
  surf(xtest1,xtest2,reshape(class_pdf(yy,:),[length(xtest2) length(xtest1)]))
  xlabel('x^{(1)}')
  ylabel('x^{(2)}')
  colorbar('FontName','Helvetica','FontSize',10)
  set(gcf,'PaperUnits','centimeters');
  set(gcf,'PaperPosition',[0 0 12 9]);
  print(['-d' print_type],sprintf('density%g',yy))
end

%True class-posterior probabilities
for yy=1:c
  figure(200+yy), clf, hold on
  set(gca,'FontName','Helvetica','FontSize',10)
  title(sprintf('True class-posterior probabilities p(y=%g|x)',yy))
  surf(xtest1,xtest2,reshape(class_posterior(yy,:),...
			     [length(xtest2) length(xtest1)]))
  xlabel('x^{(1)}')
  ylabel('x^{(2)}')
  colorbar('FontName','Helvetica','FontSize',10)
  set(gcf,'PaperUnits','centimeters');
  set(gcf,'PaperPosition',[0 0 12 9]);
  print(['-d' print_type],sprintf('true%g',yy))
end

%LSPC-estimated class-posterior probabilities
for yy=1:c
  figure(300+yy), clf, hold on
  set(gca,'FontName','Helvetica','FontSize',10)
  title(sprintf('LSPC-estimatred class-posterior probabilities p-hat(y=%g|x)',yy))
  surf(xtest1,xtest2,reshape(class_posterior_LSPC(yy,:),...
			     [length(xtest2) length(xtest1)]))
  xlabel('x^{(1)}')
  ylabel('x^{(2)}')
  colorbar('FontName','Helvetica','FontSize',10)
  set(gcf,'PaperUnits','centimeters');
  set(gcf,'PaperPosition',[0 0 12 9]);
  print(['-d' print_type],sprintf('LSPC%g',yy))
end
