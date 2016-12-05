function [] = xplot_title(alpha,metric,measure)
%function [] = xplot_title(alpha,metric,measure)

alphastr = int2str(100*alpha);
if nargin < 3,
   measure = 'PDC';
end;
measure = upper(measure);
metric = lower(metric);
switch metric
   case 'euc'

   case 'diag'
      if measure == 'DTF',
         measure = 'DC';
      else
         measure = 'gPDC';
      end;
   case 'info'
      measure = ['i' measure];
   otherwise
      error('Unknown metric.')
end;

suptitle([measure ' (' '{\alpha = ' alphastr '%}' ')'])