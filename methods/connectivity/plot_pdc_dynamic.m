function plot_pdc_dynamic(data,varargin)

p = inputParser();
fs_default = 1;
addRequired(p,'data',@isstruct);
addParameter(p,'w_max',0.5,@(x) isnumeric(x) && x <= 0.5); % not sure about this
addParameter(p,'fs',fs_default,@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
parse(p,data,varargin{:});

dims = size(data.pdc);
ndims = length(dims);
if ndims == 4
    % dynamic pdc
    [nsamples,nchannels,~,nfreqs]=size(data.pdc); 
else
    error('requires dynamic pdc data');
end

fs = p.Results.fs;

w_max = p.Results.w_max;
w = 0:fs/(2*nfreqs):w_max-fs/(2*nfreqs);
nPlotPoints = length(w);
w_min = w(1);

hylabel = 0;
hxlabel = 0;
ytick = linspace(w_min, w_max, 5);

for j=1:nchannels
    for i=1:nchannels
        % data
        if j ~= i
            h = subplot2(nchannels, nchannels, (i-1)*nchannels + j);
            
            %data_plot = zeros(nPlotPoints,nsamples);
            data_plot = abs(squeeze(data.pdc(:,i,j,1:nPlotPoints))');
%             for n=1:nsamples
%                 
%                 % TODO maybe this would be faster by squeezing
%                 % data_plot = abs(squeeze(data.pdc(:,i,j,1:nPlotPoints))');
%                 data_plot(:,n) = abs(get_dynamic_Cij(data.pdc,n,i,j,nPlotPoints));
%                 %Cohtmp        = abs(getCij(Coh,r,s,nPlotPoints));
%                 
%             end
            
            clim = [0 1];
            imagesc(data_plot,clim);
        end
        
        % axis label
        if i == N,
            if j == 1,
               hylabel(i) = labelity(i,p.Results.ChannelLabels);
               hxlabel(j) = labelitx(j,p.Results.ChannelLabels);
               
               set(h,...
                   'YTick', ytick, ...
                   'YTickLabel',[' 0';'  ';'  ';'  ';'  ';'.5'], ...
                   'FontSize',10)%, ...
               % 'YTick',[0 .5 1],'YTickLabel',[' 0';'.5';' 1']);
            else
               hxlabel(j) = labelitx(j,p.Results.ChannelLabels);
               set(h,...
                  'YTick', ytick, ...
                  'YTickLabel',[' ';' ';' ';' ';' ';' '])%, ...
               %'YTick',[0 .5 1]);%,'YTickLabel',['  ';'  ';'  ']);
            end;
         elseif j == 1,
            hylabel(i) = labelity(i,p.Results.ChannelLabels);
            set(h,...
               'YTick', ytick, ...
               'YTickLabel',[' ';' ';' ';' ';' ';' '], ... % 'YTick',[0 .5 1], ... %, 'YTickLabel',['  '; '  '; '  '], ...
               'FontSize',10);
            if i == N,
               set(h,'FontSize',10,'FontWeight','bold'); %, ...
               %                 'YTick',[0 .5 1]); %, 'YTickLabel',[' 0'; '.5'; ' 1']);
            end;
         else
            set(h,...
               'YTick', ytick, ...
               'YTickLabel',[' ';' ';' ';' ';' ';' '], ...
               'FontSize',10) %, ...               'YTick',[0 .5 1]);%, 'YTickLabel',['  '; '  '; '  ']);
         end;
    end
end

end

% function c = get_dynamic_Cij(C,n,i,j,nFreq)
% %function c = get_dynamic_Cij(C,n,i,j,nFreq)
% % 
% %   Input
% %   -----
% %   C
% %       data
% %   n
% %       sample index
% %   i
% %       row channel index
% %   j 
% %       column channel index
% %   nFreq
% %       number of frequency values
% %       
% %   Output
% %   ------
% %   c
% %       C[n,i,j] element
% 
% p = inputParser();
% addRequired(p,'C',@(x) length(size(x)) == 4);
% parse(p,C);
% 
% if nargin < 4,
%    [Ns Nch Nch nFreq] = size(C);
% end;
% c=reshape(C(n,i,j,1:nFreq), nFreq,1,1,1,1);
% 
% end

function [hxlabel] = labelitx(j,chLabels) % Labels x-axis plottings
if isempty(chLabels)
   hxlabel=xlabel(['j = ' int2str(j)]);
   set(hxlabel,'FontSize',12, ... %'FontWeight','bold', ...
      'FontName','Arial') % 'FontName','Arial'
else
   hxlabel=xlabel([chLabels{j}]);
   set(hxlabel,'FontSize',12) %'FontWeight','bold')
end
end

%% ========================================================================

function [hylabel] = labelity(i,chLabels) % Labels y-axis plottings
if isempty(chLabels)
   hylabel=ylabel(['i = ' int2str(i)],...
      'Rotation',90);
   set(hylabel,'FontSize',12, ... %'FontWeight','bold', ...
      'FontName','Arial')  % 'FontName','Arial', 'Times'
else
   hylabel=ylabel([chLabels{i}]);
   set(hylabel,'FontSize',12); %'FontWeight','bold','Color',[0 0 0])
end
end