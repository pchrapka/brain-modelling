function plot_rc_feature_matrix(data,varargin)
%PLOT_RC_FEATURE_MATRIX plots reflection coefficients from feature mtrix
%   PLOT_RC_FEATURE_MATRIX(data,...) plots reflection coefficients from
%   feature mtrix
%
%   Input
%   -----
%   data (struct)
%       data struct from bricks.features_matrix step, requires the
%       following fields:
%
%       feature_labels (cell array) 
%           feature labels
%       samples (matrix)
%           feature matrix with size [samples features]
%       class_labels (vector)
%           class labels for each sample
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
%       movie-order
%           plots reflection coefficients at each time step, where each
%           order is plotted in its own subplot
%       movie-max
%           plots the max reflection coefficient at each time step
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
p.KeepUnmatched = true;
addRequired(p,'data',@isstruct);
addParameter(p,'mode','boxplot',@ischar);
% p.addParameter('clim',[-1.5 1.5],@(x) isvector(x) || isequal(x,'none'));
% p.addParameter('abs',false,@islogical);
% p.addParameter('threshold','none',@(x) isnumeric(x) || isequal(x,'none'));
p.parse(data,varargin{:});

switch p.Results.mode
    case 'boxplot'
        params = struct2namevalue(p.Unmatched);
        plot_rc_feature_matrix_boxplot(data,params{:});
    otherwise
        error('unknwon plot mode %s',p.Results.mode);
end

end