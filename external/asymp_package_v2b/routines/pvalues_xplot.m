% Connectivity plot in matrix layout with power spectra in the main
% diagonal.
%
%[hxlabel,hylabel] = pvalue_xplot(c, ...
%                          flgPrinting,fs,w_max,chLabels,flgColors)
%
% input: c.{SS,Coh,L,Lpatnaik,LTra,L2vinf,L2vsup,metric}- data structure
%        flgPrinting= [1 1 1 1 1 0 1]; %Not used
%         blue-line    | | | | | | 7 Spectra (0: w/o; 1: Linear; 2: Log)
%         gray         | | | | | 6 Coherence
%         dashed-blue  | | | | 5 Plot lower confidence limit
%         dashed-blue  | | | 4 Plot upper confidence limit
%         red          | | 3 Significant PDC in red line
%         dashed-black | 2 Patnaik threshold level in black dashed-line
%         green        1 PDC in green line or black w/o statistics
%
%        fs - sampling frequency
%        w_max - frequency scale upper-limit
%        chLabels - channel identification labels
%        flgColors - 0 or 1 for PDC 0.1 and 0.01 y-axis rescaling
%
% output: graphics
%         hxlabel, hylabel = graphic label's handles
%
% Examples: Calculate c using alg_pdc.
%
%           pvalue_xplot(c); % Defaults flgPrinting, fs, w_max and flgColor
%
%           pvalue_xplot(c,[1 1 1 0 0 1 1],200,100,[],0);
%                        % PDC, threshold, power spectra, coherence
%                        % plotted. fs=200 Hz; default channel label;
%                        % flgColor=0 => no color or rescalling is used.



function [hxlabel,hylabel] = pvalue_xplot(c,...
   flgPrinting,fs,w_max,chLabels,flgColor)
knargin = 6;     % Number of input arguments
SS = c.SS;       % Spectra
Coh = c.coh;     % Coh^2
L = c.pdc;       % PDC^2 (N x N x freq)
Lpatnaik = c.th; % Patnaik threshold values for alpha
pvalues = c.pvalues;
L2vinf = c.ic1;
L2vsup = c.ic2;
LTra   = c.pdc_th; % Significant PDC^2 on freq range, otherwise = NaN.
metric = c.metric; % Valid optons: "euc", "diag" or "info"
[N,q,nFreqs]=size(L); % N=q = Number of channels/time series;
%                     % nFreqs = number of points on frequency scale
nodesett=1:N;

if nargin <  (knargin-4),  flgPrinting = [1 1 1 0 0 0 1]; end;
if nargin <= (knargin-4),  fs=1; end
if nargin < (knargin-2),   w_max = fs/2; end
if nargin < knargin,       flgColor = 0; end;

if w_max > fs/2 + eps,
   error(['The parameter w_max should be =< Nyquist frequency,' ...
      'i.e, w_max <= fs/2.'])
end;

flgPrinting = [1 1 1 0 0 0 0];

w = 0:fs/(2*nFreqs):w_max-fs/(2*nFreqs);
nPlotPoints = length(w);
w_min = w(1);

if nargin < (knargin-1) || isempty(chLabels),
   if isfield(c,'chLabels'),
      chLabels=c.chLabels;
   else
      chLabels=[];
   end;
   if ~isempty(chLabels) && max(size(chLabels)) < N,
      error('1 NOT ENOUGH CHANNEL LABELS.');
   end;
elseif max(size(chLabels)) < N,
   if isfield(c,'chLabels'),
      chLabels=c.chLabels;
   else
      chLabels=[];
   end;
   if ~isempty(chLabels) && max(size(chLabels)) < N,
      error('2 NOT ENOUGH CHANNEL LABELS 2.');
   else
      disp('3 NOT ENOUGH CHANNEL LABELS. Default labels assumed.');
   end;
end;

hxlabel=0; % x-axis labels' handles
hylabel=0; % y-axis labels' handles
for j = 1:N
   s=nodesett(j);
   for i=1:N,
      r=nodesett(i);
      if j ~= i || ( j == i && flgPrinting(7) ~= 0)
         h=subplot2(N,N,(i-1)*N+j);
      end;
      %==========================================================================
      %                       Power spectrum plottinga
      %==========================================================================

      if j == 1,
         hylabel(i)=labelity(i,chLabels);
      end;
      if j == N,
         hxlabel(j)=labelitx(j,chLabels);
      end;
      %==========================================================================
      %                      PDC and coherence plotting
      %==========================================================================
      %======================================================================
      %                         Labeling axis
      %======================================================================

      hold on

      %==========================================================================
      %==========================================================================

      atrib='k-'; % Patnaik significance level in black line
      plot(w,getCij(pvalues,r,s,nPlotPoints),atrib, ...
         'LineWidth',2);
      axis([0 max(w) 0 1])

   end;
end;

supAxes=[.08 .08 .84 .84];

 [ax2,h2]=suplabel('p-values_{PDC}'  ,'t');

[ax1,h1]=suplabel('Frequency','x',supAxes);
set(h1, 'FontSize',[14], 'FontWeight', 'bold')

%==========================================================================
function [hxlabel]=labelitx(j,chLabels) % Labels x-axis plottings
if isempty(chLabels)
   hxlabel=xlabel(['\bf{\it{j}} \rm{\bf{ = ' int2str(j) '}}']);
   set(hxlabel,'FontSize',[14],'FontWeight','bold', ...
      'FontName','Times')
else
   hxlabel=xlabel([chLabels{j}]);
   set(hxlabel,'FontSize',[12],'FontWeight','bold','FontName', 'Arial')
end;

%==========================================================================
function [hylabel]=labelity(i,chLabels) % Labels y-axis plottings
if isempty(chLabels)
   hylabel=ylabel(['\bf{\it{i}} \rm{\bf{ = ' int2str(i) '}}'],...
      'Rotation',90);
   set(hylabel,'FontSize',[14],'FontWeight','bold', ...
      'FontName','Times')
else
   hylabel=ylabel([chLabels{i}]);
   set(hylabel,'FontSize',[12],'FontWeight','bold','FontName', 'Arial','Color',[0 0 0])
end;

%==========================================================================
