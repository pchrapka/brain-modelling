function lattice = estimate_reflection_coefs(lattice, x)

%   Input
%   -----
%   lattice (struct array)
%       lattice filter configurations, specified as a struct array with the
%       following fields
%   
%       lattice.alg (object)
%           algorithm object initialized, see QRDLSL, GAL, BurgWindow
%
%   x (vector)
%       measurements
%
%   Output
%   ------
%   lattice (struct array)
%       input augmented with the following fields
%
%       lattice.alg
%           updated algorithm object
%       lattice.K (matrix)
%           reflection coefficients [Order x Samples], depending on
%           algorithm, empty if not used
%       lattice.Kf
%           forward reflection coefficients [Order x Samples], depending on
%           algorithm, empty if not used
%       lattice.Kb
%           backward reflection coefficients [Order x Samples], depending
%           on algorithm, empty if not used

% get sizes
nsamples = length(x);
nfilters = length(lattice);

% init reflection coef matrices
for j=1:nfilters
    
    % set up empty matrices
    lattice(j).K = [];
    lattice(j).Kf = [];
    lattice(j).Kb = [];
    
    M = lattice(j).alg.M;
    
    if isprop(lattice(j).alg, 'K')
        lattice(j).K = zeros(M,nsamples);
    else
        lattice(j).Kf = zeros(M,nsamples);
        lattice(j).Kb = zeros(M,nsamples);
    end
end

% compute reflection coef estimates
for i=1:nsamples
    
    for j=1:nfilters
        % update the filter with the new measurement
        lattice(j).alg.update(x(i));
        
        % copy reflection coefficients
        if isempty(lattice(j).K)
            lattice(j).Kf(:,i) = lattice(j).alg.Kf;
            lattice(j).Kb(:,i) = lattice(j).alg.Kb;
        else
            lattice(j).K(:,i) = lattice(j).alg.K;
        end
    end
end

end