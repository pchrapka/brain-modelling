function [lattice,errors] = estimate_reflection_coefs(lattice, x, varargin)
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
%   verbose (integer, default = 0)
%       selects verbosity of output, 0,1,2
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
%
%   errors (struct array)
%       warning messages from each iteration, struct contains the following
%       fields:
%       msg (string)
%           warning message
%       warning (boolean)
%           

if nargin > 2
    verbose = varargin{1};
else
    verbose = 0;
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
[errors(1:nsamples).warning] = deal(false);
[errors(1:nsamples).msg] = deal('');
for i=1:nsamples
    if verbose > 1
        fprintf('sample %d\n',i);
    end
    
    for j=1:nfilters
        % clear the last warning
        lastwarn('');
        
        % update the filter with the new measurement
        lattice(j).alg.update(x(:,i));
        
        % check last warning
        [~, lastid] = lastwarn();
        if isequal(lastid,'MATLAB:singularMatrix')
            errors(i).warning = true;
            errors(i).msg = lastid;
        end
        
        
        % copy reflection coefficients
        if isempty(lattice(j).K)
            lattice(j).Kf(i,:,:,:) = lattice(j).alg.Kf;
            lattice(j).Kb(i,:,:,:) = lattice(j).alg.Kb;
        else
            lattice(j).K(i,:) = lattice(j).alg.K;
        end
    end
end

if verbose > 0
    if sum([errors.warning]) > 0
        error_idx = [errors.warning];
        % get error indices
        idx = 1:length(errors);
        error_mat = idx(error_idx);
        % set up formatting
        cols = 10;
        rows = ceil(length(error_mat)/cols);
        if length(error_mat) < cols*rows
            error_mat(cols*rows) = 0; % extend with 0
        end
        fprintf('warnings at:\n');
        for i=1:rows
            idx_start = (i-1)*cols + 1;
            idx_end = idx_start -1 + cols;
            row = error_mat(idx_start:idx_end);
            fprintf('\t');
            fprintf('%d ', row);
            fprintf('\n');
        end
    end
end

end