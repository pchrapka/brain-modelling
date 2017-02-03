function plot_rc_dynamic(data,varargin)
%PLOT_RC_DYNAMIC plots dynamic reflection coefficients
%   PLOT_RC_DYNAMIC(data,...) plots dynamic reflection coefficients
%
%   Input
%   -----
%   data (matrix)
%       reflection coefficients from LatticeTrace object, i.e. the Kf or Kb
%       field, [samples order channel channel]
%
%   Parameters
%   ----------
%   clim (vector or 'none', default = [-1.2 1.2])
%       color limits for image plots
%
%   abs (logical, default = false)
%       plots absolute value of coefficients
%
%   threshold (numeric or 'none', default = 'none')
%       reflection coefficients outside of this range are set to NaNs

p = inputParser();
addRequired(p,'data',@isnumeric);
addParameter(p,'ChannelLabels',{},@iscell);
addParameter(p,'clim',[-1.2 1.2],@(x) isvector(x) || isequal(x,'none'));
addParameter(p,'abs',false,@islogical);
addParameter(p,'threshold','none',@(x) isscalar(x) || isequal(x,'none'));
parse(p,data,varargin{:});

dims = size(data);
ndims = length(dims);
if ndims == 4
    %nsamples = dims(1);
    if dims(2) == dims(3)
        format_orig = 3;
        %norder = dims(4);
        nchannels = dims(2);
    elseif dims(3) == dims(4)
        format_orig = 1;
        %norder = dims(2);
        nchannels = dims(4);
    else
        error('unknown coefficient format');
    end
else
    error('requires dynamic rc data');
end

% transform data based on parameters
data = transform_data(data,p.Results);

hylabel = 0;
hxlabel = 0;
h = [];

for j=1:nchannels
    for i=1:nchannels
        % data
        h = subplot2(nchannels, nchannels, (i-1)*nchannels + j);
        
        switch format_orig
            case 3
                data_plot = squeeze(data(:,i,j,:))';
            case 1
                data_plot = squeeze(data(:,:,i,j))';
        end
        
        imagesc(data_plot,p.Results.clim);
        
        % axis label
        if i == nchannels,
            if j == 1,
               hylabel(i) = labelity(i,p.Results.ChannelLabels);
               hxlabel(j) = labelitx(j,p.Results.ChannelLabels);
            elseif j == nchannels
                hxlabel(j) = labelitx(j,p.Results.ChannelLabels);
                set(h,...
                    'YtickLabel', []);
                
                % add colorbar to last axis
                %h1 = subplot2(nchannels, nchannels, (i-1)*nchannels + j);
                %axis off;
                %colorbar(h1,'peer',h);
                colorbar('East');
            else
                hxlabel(j) = labelitx(j,p.Results.ChannelLabels);
                set(h,...
                    'YtickLabel', []);
            end
        elseif j == 1,
            hylabel(i) = labelity(i,p.Results.ChannelLabels);
            set(h,...
                'XtickLabel', []);
            if i == nchannels,
                set(h,'FontSize',10,'FontWeight','bold');
            end;
        else
            set(h,...
                'XtickLabel', [],...
                'YtickLabel', []);
        end
    end
end

end

%% ========================================================================

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

%% ========================================================================

function data = transform_data(data,params)
if params.abs
    data = abs(data);
end
if ~isequal(params.threshold,'none')
    data(data > params.threshold) = NaN;
    data(data < -params.threshold) = NaN;
end
end