%PDC analysis getting started template file
%
% Edit this file to analyze your data. You might want to choose analysis
% parameters followed by comment containing "<***>". Check bellow.
%
% Some important input and output parameters and variables:
% input:
%        u     - data in columns
%        fs    - Sampling frequency 
%        maxIP - externally defined maximum IP
%        alg   - for algorithm (1: Nutall-Strand),(2: mlsm) ,
%                              (3: Vieira Morf),  (4: ARfit)
%        criterion - for AR order selection =>
%                                   1: AIC; 2: Hanna-Quinn; 3: Schwartz;
%                                   4: FPE, 5: fixed order in MaxIP
%        alpha  -  PDC test significance level
%
% output: 
%         c.pdc - original/generalized/informational PDC
%         c.th -  threshold level by Patnaik approximation
%         c.pdc_th - above threshold pdc values otherwise equal NaN
%         c.ic1,c.ic2 - superior and inferior confidence interval
%         c.p - VAR model order
%         c.SS - Power spectrum
%         c.coh - coherece function


%===========================#
% Times series for analysis /
%===========================#
% u     - data in columns.
%         The variable u must contain the time series
%         If flgExample=1 the template file will analyze a
%         5 variables Gaussian independent noises.

format compact
clear all; clc

% Choose Example 1 == Five independent random variables model
%                2 == Sunspot-melanoma time series
%                3 == Baccala & Sameshima (2001) 5 variables linear model
%                4 == Takahashi(2009) Thesis' example model                
flgExample=2;

disp('======================================================================');
disp('============= PDC analysis getting started template ==================')
disp('======================================================================');

switch flgExample
   case 1,
      u=randn(2000,5);    %<***> Example (1)
      disp('            Random Independent Process with 5 variables')
      disp('======================================================================');

   case 2
      u=sunmeladat([4 3]); %<***> Example (2)
      disp('     Andrews and Herzberg''s Sunspot and Melanoma Example');
      disp('                 Sunspot --> Melanoma or other way?');
      disp('======================================================================');
   case 3
      u=baccala2001a_ex5data(200);
   case 4,
      u=takahashi_thesis_dat(200);
   otherwise
      error('Wrong example selection.')
end;

fs = 1; %<***> Sampling frequency

[nSegLength,nChannels]=size(u);
if nSegLength < nChannels, error('The data might be transposed.'); end;

%===========================#
%  Channel identification   /
%===========================#

switch flgExample
  case 1,
    chLabels  = {'x_1';'x_2';'x_3';'x_4';'x_5'}; %<***> Example (1)
    strTitle2 = 'Five independent Gaussian noises '; %Title info
  case 2
    chLabels  = {'Sunspot';'Melanoma'}; %<***> Example (2)
    strTitle2 = 'Sunspot & Melanoma 1936-1972 ';
  case 3,
    chLabels  = [];                     %<***> Example (3)
    strTitle2 = 'Five variables Baccal?+Sameshima(2001) examples ';
  case 4,
    chLabels  = {'X'; 'Y'; 'Z'};        % Takahashi thesis example
    strTitle2 = 'Takahashi 2008 (Thesis) example';
end;

flgLabels = ~isempty(chLabels);
if flgLabels,
  if nChannels ~= max(size(chLabels))
    error('Numbers of labels and channels do not match.')
  end;
end;

%===========================#
%       Action flags        /
%===========================#
flgDetrend = 1;   %<***> Usually it's recommended to detrend the time series.

flgStandardize = 1; %<***> For PDCn estimation standardization has no effect.

if flgStandardize,
  disp('Be aware that the data standardization does not affect the generalized')
  disp('   PDC estimates nor its statistics results, so that data standardization')
  disp('   is not necessary.')
end;

%===========================#
%    Analysis parameters    /
%===========================#
nFreqs = 128; %<***> number of points on frequency scale; 
              %      use either 64 or 128.

metric = 'euc';
%        metric   'euc'  - Euclidean     -> original PDC;
%                 'diag' - diagonal      -> gPDC;
%                 'info' - informational -> iPDC;

maxIP = 30; % maxIP - externally defined maximum IP %<***>

%===========================#
%    MAR algorithm          /
%===========================#
% Choose one of algorithm for MAR estimation
% alg   - for algorithm  (1: Nutall-Strand),(2: mlsm) ,
%                        (3: Vieira Morf),  (4: QR artfit)
alg = 1; %<***> Nuttall-Strand (alg=1) algorithm, it seems to be a good 
       %      and robust method.

%============================#
%MAR order selection criteria/
%============================#
% criterion - for AR order choice
%  1: AIC; 2: Hanna-Quinn; 3: Schwartz;
%  4: FPE, 5: fixed order in MaxIP
criterion = 1; %<***> AIC, Akaike information criterion (Our preferred one)

%==================
alpha = 0.01;        %<***> Significance level for PDC null hypothesis 
                     % testing, it is usually 1% or 5%
                     %
                     % IMPORTANT: if alpha == 0, no asymptotic statistics 
                     % calculation is performed and ASYMP_PDC (see bellow) 
                     % will only returns PDC. This option is interesting 
                     % if you want faster PDC calculation.
                     %
gct_signif = alpha;  % Granger causality test significance. Choose other 
                     % value if you have good reason for using different 
                     % one from PDC statistical testing. 
igct_signif = alpha; % Instantaneous Granger causality test significance level.
VARadequacy_signif = 0.05; % VAR model adequacy significance level

%==========================================================================
%                    Plotting options
%==========================================================================

% The following parameters are used by xplot routine

%             [1 2 3 4 5 6 7]
flgPrinting = [1 1 1 3 3 0 2]; % See xplot.m for more detail.
%              | | | | | | 7 Power Spectra (0: w/o SS; 1: Linear; 2: Log-scale)
%              | | | | | 6 Coherence in gray line
%              | | | | 5 Confidence interval
%              | | | 4 Confidence interval(1:dashed;2:shaded;3:error barr
%              | | 3 Plot PDC in red line
%              | 2 Patnaik threshold level in black dashed-line
%              1 PDC in green line

flgColor = 1; % Choosing background color for exposing y-axis scale
%        flgColor - 0: white background;
%                   1: white [.1 1], light-blue [.01 .1], purple [0 .01]
%                   2: white [.1 1], light-gray [.01 .1], gray [0 .01]
flgScale = [1 2 3];     
%        flgScale - 1: [0 1] / {if max(PDC/DTF) > 1}:[0 max(PDC/DTF)]
%                   2: [0 {if max(PDC/DTF) > 1}:max(PDC/DTF)]/[0 1]/[0 .1]/[0 .01]
%                                     based on flgMax(PDC/DTF/Threshold/CI/all)
%                   3: [0 max(PDC/DTF/Thr/CI/all)]
%                                     based on flgMax(PDC/DTF/Threshold/CI/all)
%        Plotting option for scaling y-axis according to the max 
%        amplitude either of: 
%                  PDC/DTF - max value of these measures, 
%                  Thr - max Patnaik threshold,
%                  CI - max upper confidence interval value, max of
%                  TCI - max Threshold or confidence value, or 
%                  all - max of all of them.
%               chosen by flgMax for eventually exposing small values
%               detail of PDC/DTF.
flgMax = 'TCI';
%        flgMax - {'PDC'; 'DTF'; 'Thr'; 'CI'; 'TCI'; 'all'} measure used as
%                   upper limit for scale. See flgScale.
flgSignifColor = 3;
%        flgSignifColor -  0: black lines
%                          1: black / gray -> significant /not signif PDC/DTF
%                          2: red  /  gray ->      "
%                          3: red  / green ->      "
%                          4: red  / black ->      "
%                          5: black / green ->     "

axis_scale = [0 0.50 -0.02 1.05];
w = fs*(0:(nFreqs-1))/2/nFreqs;
w_max = fs/2; %<***> Usually half of sampling frequency = Nyquist frequency


%==========================================================================
%==========================================================================
%        ATTENTION: BELOW THIS LINE PROBABLY YOU MIGHT NOT WANT TO EDIT,
%            UNLESS YOU WANT TO CUSTOMIZE YOUR ANALYSIS ROUTINE.
%==========================================================================

%==========================================================================
%                    Detrend and standardization options
%==========================================================================

[nChannels,nSegLength]=size(u);
if nChannels > nSegLength, u=u.'; 
   [nChannels,nSegLength]=size(u);
end;

if flgDetrend,
   for i=1:nChannels, u(i,:)=detrend(u(i,:)); end;
   disp('Time series were detrended.');
end;

if flgStandardize,
   for i=1:nChannels, u(i,:)=u(i,:)/std(u(i,:)); end;
   disp('Time series were scale-standardized.');
end;



%==========================================================================
% Additional info for title (optional)

strTitle1 = ['PDC(' '{\alpha = ' int2str(100*alpha) '%}' ') '];
switch metric
   case 'euc'
      %NOP
   case 'diag'
      strTitle1 = ['g' strTitle1];
   case 'info'
      strTitle1 = ['i' strTitle1];
   otherwise
      error('Unknown metric.')
end;
% or set strTitle1 = [];

%==================
switch alg
  case 1
    disp('VAR estimation using Nutall-Strand algorithm.')
  case 2
    disp('VAR estimation using least-squares estimator.')
  case 3
    disp('VAR estimation using Vieira-Morf algorithm.')
  case 4
    disp('VAR estimation using QR-Arfit algorithm.')
end;

%============================#
%MAR order selection criteria/
%============================#
switch criterion
   case 1
      disp('Model order selection criteria: AIC.')
   case 2
      disp('Model order selection criteria: Hanna-Quinn.')
   case 3
      disp('Model order selection criteria: Schwartz (BIC).')
   case 4
      disp('Model order selection criteria: FPE.')
   case 5
      disp('Model order selection criteria: fixed order in maxIP.')
   otherwise
      error('Model order selection criteria: NOT IMPLEMENTED YET.')
end;

%==========================================================================
%                            VAR model estimation
%==========================================================================
[IP,pf,A,pb,B,ef,eb,vaic,Vaicv] = mvar(u,maxIP,alg,criterion);


disp(['Number of channels = ' int2str(nChannels) ' with ' ...
  int2str(nSegLength) ' data points; MAR model order = ' int2str(IP) '.']);

%==========================================================================
%    Testing for adequacy of MAR model fitting through Portmanteau test
%==========================================================================
   h = 20; % testing lag
   aValueVAR = 1 - VARadequacy_signif;
   flgPrintResults = 1;
[Pass,Portmanteau,st,ths]=mvarresidue(ef,nSegLength,IP,aValueVAR,h,...
                                                          flgPrintResults);

%==========================================================================
%         Granger causality test (GCT) and instantaneous GCT
%==========================================================================
   flgPrintResults = 1;
[Tr_gct, pValue_gct, Tr_igct, pValue_igct] = gct_alg(u,A,pf,gct_signif, ...
                                                         flgPrintResults);

%==========================================================================
%            PDC, threshold and confidence interval calculation.
%==========================================================================

% if alpha == 0, no asymptotic statistics is performed. ASYMP_PDC returns
% only the PDC. This option is much faster!!
 c=asymp_pdc(u,A,pf,nFreqs,metric,alpha);

% Power spectra and coherence calculation
c.SS = ss_alg(A, pf, nFreqs);
c.coh = coh_alg(c.SS);

% Statistically significant PDC on frequency scale
if alpha ~= 0,
   pdc_temp = ((abs(c.pdc)-c.th) > 0).*c.pdc + ((abs(c.pdc)-c.th) <= 0)*(-1);
   pdc_temp(ind2sub(size(pdc_temp),find(pdc_temp == -1))) = NaN;
   c.pdc_th = pdc_temp;
end;

%Adding further analysis details in the figure title.
%strTitle3 = ['[N=' int2str(nSegLength) '; IP=' int2str(c.p) ']'];
% or

strTitle3 = ['[N=' int2str(nSegLength) 'pts; IP=' int2str(c.p) '; ' ...
   datestr(now) ']'];

% or leave emptied: strTitle3=[];

%==========================================================================
%              Matrix Layout Plotting of the Analysis Results
%==========================================================================

w_max = fs/2;
strTitle = [strTitle1 strTitle2 strTitle3];
strWindowName = 'pdc Analysis Template Example';


% The following "for loop" through flgColor values, 0 and 1, and yields a
% pair of plots, one without and other with color scale rearrangement option.
% Value range of PDC and Coherence is from [0 1], but sometimes the maximum 
% peak value is small (<0.1), or even smaller, (<.01), so in these cases it
% might be interesting to have a plot with finer smaller y-axis scale. The
% white-background plot indicates full-scale [0 1] y-axis, while
% light-blue-background stands for intermediate [0 .1] scaling and
% light-purple-background shows very fine detail of small, usually not
% significant PDCs. Try flgColor = 0 or 1, or both [0 1].

for kflgScale = flgScale,
   h=figure;
   set(h,'NumberTitle','off','MenuBar','none', ...
      'Name', strWindowName )

   [hxlabel,hylabel] = xplot(c,flgPrinting,fs,w_max,chLabels, ...
                               flgColor,kflgScale,flgMax,flgSignifColor)
   
% The title suplabel command should (not sure) follow the xplot routine
% In MacOS X, for flgPrinting(7) = 4 or 5, the main diagonal plotting
% gets misaligned if suplabel with 't' option is used more than once.

   [ax,hT]=suplabel( strTitle, 't' );
   set(hT,'FontSize',8) 
end;

tilefigs

%=========================== xplot ========================================
%Plot legend:  Blue lines on the main diagonal = Power spectra;
%              Black dashed lines are Patnaik threshold for pdcn;
%              Green lines = non significant pdcn;
%              Red lines = significant pdcn;
%              Light-gray lines = coherence function.
%
% Notes:       a.The main diagonal of matrix layout contains power spectra.
%              b.Coherences are symmetric, e.g., 
%                   Coh_{Sunspot,Melanoma}(f) = Coh_{Melanoma,Sunspot}(f).
%              c.pdcn is asymmetric relation, and the pdcn graphics should
%              be read as if the flow of information is been from the
%              x-axis variable toward y-axis variable.
%
%              For sunspot and melanoma example, one only sees significant
%              pdcn from Sunspot to Melanoma, which could eventually be
%              interpreted that "Sunspot", or the Sun's activity
%              modulates the incidence of melanoma.
%======================= pdc_xplot ========================================
disp('======================================================================');
disp('===========pdc_ANALYSIS_TEMPLATE SUCCESSFULLY FINISHED ===============')
disp('======================================================================');
