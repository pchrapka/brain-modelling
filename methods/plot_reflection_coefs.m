function plot_reflection_coefs(k_est, k_true, nsamples)
%PLOT_REFLECTION_COEFS plots estimated and true reflection coefficients
%   PLOT_REFLECTION_COEFS(K_EST, K_TRUE, NSAMPLES) plots both estimated and
%   true reflection coefficients
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

% number of coefs
M = size(k_true,1);
% number of samples
if nargin < 3
    nsamples = size(k_true,2);
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
        title('Reflection Coefficient Estimate');
    end
    
    hold on;
    for j=1:nfilters
        if isempty(k_est(j).K)
            plot(1:nsamples, k_est(j).scale*k_est(j).Kf(k,1:nsamples));
            if k==1
                legend_str = [legend_str [k_est(j).name ' Kf']];
            end
            plot(1:nsamples, k_est(j).scale*k_est(j).Kb(k,1:nsamples));
            if k==1
                legend_str = [legend_str [k_est(j).name ' Kb']];
            end
        else
            plot(1:nsamples, k_est(j).scale*k_est(j).K(k,1:nsamples));
            if k==1
                legend_str = [legend_str [k_est(j).name ' K']];
            end
        end
    end
end
legend(legend_str, 'Location','Best');

end