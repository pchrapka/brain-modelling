function lattice = estimate_reflection_coefs(lattice, x, varargin)
%ESTIMATE_REFLECTION_COEFS estimates reflection coefficients of X
%   [lattice] = ESTIMATE_REFLECTION_COEFS(lattice, x, [verbose])
%   Input
%   -----
%   lattice (struct array)
%       lattice filter configurations, specified as a struct array with the
%       following fields
%   
%       lattice.alg (object)
%           algorithm object initialized, see QRDLSL, GAL, BurgWindow
%
%   x (matrix)
%       measurements, [channels nsamples]
%
%   verbose (boolean, default = false)
%       selects verbosity of output
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

if nargin > 2
    verbose = varargin{1};
else
    verbose = false;
end

% get sizes
nsamples = size(x,2);
nfilters = length(lattice);

% init reflection coef matrices
for j=1:nfilters
    
    % set up empty matrices
    lattice(j).K = [];
    lattice(j).Kf = [];
    lattice(j).Kb = [];
    
    P = lattice(j).alg.order;
    
    if isprop(lattice(j).alg, 'K')
        lattice(j).K = zeros(nsamples,P);
    else
        M = lattice(j).alg.nchannels;
        if M > 1
            lattice(j).Kf = zeros(nsamples,P,M,M);
            lattice(j).Kb = zeros(nsamples,P,M,M);
        else
            lattice(j).Kf = zeros(nsamples,P);
            lattice(j).Kb = zeros(nsamples,P);
        end
    end
end

% compute reflection coef estimates
for i=1:nsamples
    if verbose
        fprintf('sample %d\n',i);
    end
    
    for j=1:nfilters
        % update the filter with the new measurement
        lattice(j).alg.update(x(:,i));
        
        % copy reflection coefficients
        if isempty(lattice(j).K)
            lattice(j).Kf(i,:,:,:) = lattice(j).alg.Kf;
            lattice(j).Kb(i,:,:,:) = lattice(j).alg.Kb;
        else
            lattice(j).K(i,:) = lattice(j).alg.K;
        end
    end
end

end