function plot_reflection_coefs(k_est, k_true, nsamples, varargin)
%PLOT_REFLECTION_COEFS plots estimated and true reflection coefficients
%   PLOT_REFLECTION_COEFS(K_EST, K_TRUE, NSAMPLES, [CH1 CH2]) plots both
%   estimated and true reflection coefficients
%
%   k_est (struct array)
%       estimated reflection coefficients, specified as a struct array
%       with the following fields
%
%       k_est.K
%           reflection coefficients if there's only one set, otherwise []
%       k_est.Kf
%           forward reflection coefficients, depending on algorithm
%       k_est.Kb
%           backward reflection coefficients, depending on algorithm
%       k_est.scale
%           scaling for reflection coefficients applied when plotting, for
%           example sometimes they may be inverted
%       k_est.name
%           name of algorithm for legend
%
%   k_true (matrix)
%       true reflection coefficients
%
%   nsamples (integer)
%       number of samples to plot, default all
%
%   Optional arguments for multichannel data
%   ch1 (integer)
%       index of first channel
%   ch2 (integer)
%       index of second channel
%

% number of coefs
M = size(k_true,1);
% number of samples
if nargin < 3
    nsamples = size(k_true,2);
end

if nargin > 3
    if ~isequal(length(varargin),2)
        error('missing a channel index');
    end
    idx1 = varargin{1};
    idx2 = varargin{2};
    multichannel = true;
else
    idx1 = 1;
    idx2 = 1;
    multichannel = false;
end

nfilters = length(k_est);

% figure layout
rows = M;
cols = 1;

legend_str = {};
for k=1:M
    subaxis(rows, cols, k,...
        'Spacing', 0, 'SpacingVert', 0.05, 'Padding', 0, 'Margin', 0.05);
    plot(1:nsamples, k_true(k,1:nsamples));
    
    if k==1
        legend_str = [legend_str 'true'];
        if multichannel
            title(sprintf('Reflection Coefficient Estimate C%d-%d',idx1,idx2));
        else
            title('Reflection Coefficient Estimate');
        end
    end
    
    hold on;
    for j=1:nfilters
        if isempty(k_est(j).K)
            plot(1:nsamples, k_est(j).scale*k_est(j).Kf(1:nsamples,k,idx1,idx2));
            if k==1
                legend_str = [legend_str [k_est(j).name ' Kf']];
            end
            plot(1:nsamples, k_est(j).scale*k_est(j).Kb(1:nsamples,k,idx1,idx2));
            if k==1
                legend_str = [legend_str [k_est(j).name ' Kb']];
            end
        else
            plot(1:nsamples, k_est(j).scale*k_est(j).K(1:nsamples,k,idx1,idx2));
            if k==1
                legend_str = [legend_str k_est(j).name];
            end
        end
    end
    ylim([-2 2]);
    
    if k ~= M
        set(gca,'XTickLabel',[]);
    end
end
legend(legend_str, 'Location','Best');

end