function plot_rc_stationary(data,varargin)
%PLOT_RC_STATIONARY plots reflection coefficients
%   PLOT_RC_STATIONARY(data,...) plots reflection coefficients
%
%   Input
%   -----
%   data (struct)
%       data struct
%   data.coef (matrix)
%       coefficient matrix [orders channels channels]
%
%   Parameters
%   ----------
%   mode (string, default = 'image-all')
%       plotting mode
%       image-all
%           plots all reflection coefficients vs time
%       image-order
%           plots reflection coefficients vs time, where each order is
%           plotted in its own subplot
%       image-max
%           plots the max reflection coefficient from all orders vs time
%
%   clim (vector or 'none', default = [-1.5 1.5])
%       color limits for image plots
%
%   abs (logical, default = false)
%       plots absolute value of coefficients
%
%   threshold (numeric or 'none', default = 'none')
%       reflection coefficients outside of this range are set to NaNs

p = inputParser();
p.addRequired('data',@isstruct);
p.addParameter('mode','image-all',@ischar);
p.addParameter('clim',[-1.5 1.5],@(x) isvector(x) || isequal(x,'none'));
p.addParameter('abs',false,@islogical);
p.addParameter('threshold','none',@(x) isnumeric(x) || isequal(x,'none'));
p.parse(data,varargin{:});

if length(size(data.coef)) > 3
    error('coefficient matrix is too big');
end

switch p.Results.mode
    
    case 'image-all'
        norder = size(data.coef,1);
        nchannels = size(data.coef,2);
        rc = zeros(nchannels,nchannels*norder);
        for j=1:norder
            idx_start = (j-1)*nchannels + 1;
            idx_end = idx_start + nchannels - 1;
            rc(:,idx_start:idx_end) = data.coef(j,:,:);
        end
        
        rc = transform_data(rc,p.Results);

        if isequal(p.Results.clim,'none')
            imagesc(rc);
        else
            imagesc(rc,p.Results.clim);
        end
        colorbar;
        title('Reflection Coefficients');
        set(gca,'yticklabel',[]);
        set(gca,'xticklabel',[]);
        
        
    case 'image-order'
        norder = size(data.coef,1);
        
        nplots = norder;
        nrows = 2;
        ncols = ceil(nplots/nrows);
        for j=1:norder
            %subplot(nrows,ncols,j);
            subaxis(nrows, ncols, j,...
                'Spacing', 0.05, 'SpacingVert', 0.05, 'Padding', 0, 'Margin', 0.05);
            rc = squeeze(data.coef(j,:,:));
            rc = transform_data(rc,p.Results);
            
            if ~isequal(p.Results.threshold,'none')
                rc(rc > p.Results.threshold) = NaN;
                rc(rc < -p.Results.threshold) = NaN;
            end
            
            if isequal(p.Results.clim,'none')
                imagesc(rc);
            else
                imagesc(rc,p.Results.clim);
            end
            axis square;
            ylabel(sprintf('P=%d',j));
            set(gca,'yticklabel',[]);
            set(gca,'xticklabel',[]);
            
            colorbar;
            % TODO fix colorbar, only displays color scale for current
            % plot, either standardize or do for all
            
            if j==norder
                xlabel('Time');
            end
        end
        
    case 'image-max'
        data_max = squeeze(max(abs(data.coef),[],1));
        rc = data_max;
        rc = transform_data(rc,p.Results);

        if isequal(p.Results.clim,'none')
            imagesc(rc);
        else
            imagesc(rc,p.Results.clim);
        end
        axis square;
        colorbar;
        xlabel('Reflection Coefficients');
        ylabel('Reflection Coefficients');
        set(gca,'yticklabel',[]);
        set(gca,'xticklabel',[]);
    
    otherwise
        error('unknown mode %s',p.Results.mode);
end

end

function data = transform_data(data,params)
if params.abs
    data = abs(data);
end
if ~isequal(params.threshold,'none')
    data(data > params.threshold) = NaN;
    data(data < -params.threshold) = NaN;
end
end