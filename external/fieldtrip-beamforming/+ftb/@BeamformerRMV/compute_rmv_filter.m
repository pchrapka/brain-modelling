function [ data ] = compute_rmv_filter( cfg )
%COMPUTE_RMV_FILTER Robust component-wise minimum variance beamformer
%   COMPUTE_RMV_FILTER(CFG) returns the weight matrix for a robust
%   beamformer for a dipole at location q_0
%
%   Input
%   cfg.H           leadfield matrix for dipole at q_0
%                   [channels x components]
%       R           covariance matrix of data 
%                   [channels x channels]
%       A           {3 x 1} cell array of matrices describing sphere of
%                   uncertainty around H
%       verbosity   toggles verbosity: 1 or 0
%       solver      (optional, default 'yalmip')
%                   'cvx'    parfor is not supported by cvx
%                   'yalmip' can be used in parfor loop
%       eigenspace  ('none', 'eig pre cov', 'eig pre leadfield', 'eig post', default 'none') 
%                   use eigenspace projection before or after optimizing
%       n_interfering_sources
%                   number of interfering sources  
%
%   Output
%   data.W          weight matrix [channels x components]
%        optval     optimal value from optimization routine
%        status     status from optimization routine
%   

% Extract variables
if ~isfield(cfg,'eigenspace'), cfg.eigenspace = 'none'; end
if isfield(cfg,'epsilon')
    error(['ftb:' mfilename],...
        'Epsilon has been deprecated, use A');
end

R = cfg.R;
A = cfg.A; %cell array
H = cfg.H;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sanity checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of channels and components
[n comp] = size(H);

% Check for valid A
if ~isequal(size(A), [comp 1])
    error(['ftb:' mfilename],...
            ['A should be ' num2str(comp) 'x' num2str(1)]);
end

% Check for valid A's
for i=1:length(A)
    if ~isequal(size(A{i}), [n n])
        error(['ftb:' mfilename],...
            ['A{' num2str(i) '} should be ' num2str(n) 'x' num2str(n)]);
    end
end

% Figure out which solver to use
if ~isfield(cfg,'solver');
    cfg.solver = 'yalmip';
elseif isequal(cfg.solver, 'cvx')
    warning(['ftb:' mfilename],...
        'cvx does not support being executed in parfor');
end

if cfg.verbosity > 0
    fprintf('Using %s solver\n',cfg.solver);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Eigenspace projection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the projection matrix
data.P = [];
if ~isequal(cfg.eigenspace, 'none')
    tmpcfg = [];
    tmpcfg.R = R;
    tmpcfg.n_interfering_sources = cfg.n_interfering_sources;
    P = util.eig_projection(tmpcfg);
    data.P = P;
end
if isequal(cfg.eigenspace,'eig pre cov')
    % Project R onto the signal+interference subspace
    R = P*R;
elseif isequal(cfg.eigenspace,'eig pre leadfield')
    % Project H onto the signal+interference subspace
    H = P*H;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use the Cholesky factorization of the data covariance
if isequal(cfg.eigenspace,'eig pre cov')
    [L,D] = ldl(R);
    U = L*sqrt(D);
else
    try
        U = chol(R); 
    catch me
        warning(me.identifier,me.message);
        data.W = zeros(size(H));
        data.optval = 0;
        data.status = 0;
        return;
    end
end

if isequal(cfg.solver, 'cvx')
    % MOSEK optimization solver
    mosek = false;
    if mosek
        cvx_solver mosek
    end
    
    error(['ftb:' mfilename],...
        'no cvx implementation');
    
    % Return the results
    data.W = W;
    data.optval = cvx_optval;
    data.status = cvx_status;
    
elseif isequal(cfg.solver,'yalmip')
    W = sdpvar(n, comp);
    t = sdpvar(1,1);
    
    Constraints = [];
    Constraints = [Constraints,...
        cone(vec(U*W), t)];
    
    Constraints = [Constraints,...
        cone(transpose(A{1})*W(:,1), (transpose(W(:,1))*H(:,1)-1))];
    Constraints = [Constraints,...
        cone(transpose(A{2})*W(:,2), (transpose(W(:,2))*H(:,2)-1))];
    Constraints = [Constraints,...
        cone(transpose(A{3})*W(:,3), (transpose(W(:,3))*H(:,3)-1))];
    
    Constraints = [Constraints,...
        cone(transpose(A{2})*W(:,1), (transpose(W(:,1))*H(:,2)))];
    Constraints = [Constraints,...
        cone(transpose(A{3})*W(:,1), (transpose(W(:,1))*H(:,3)))];
    
    Constraints = [Constraints,...
        cone(transpose(A{1})*W(:,2), (transpose(W(:,2))*H(:,1)))];
    Constraints = [Constraints,...
        cone(transpose(A{3})*W(:,2), (transpose(W(:,2))*H(:,3)))];
    
    Constraints = [Constraints,...
        cone(transpose(A{1})*W(:,3), (transpose(W(:,3))*H(:,1)))];
    Constraints = [Constraints,...
        cone(transpose(A{2})*W(:,3), (transpose(W(:,3))*H(:,2)))];
    
    Objective = t;
    options = sdpsettings('verbose',cfg.verbosity,...
        'solver','sdpt3',...
        'sdpt3.gaptol', sqrt(eps));
    sol = solvesdp(Constraints, Objective, options);
    
    if sol.problem == 0
        data.W = double(W);
        data.info = sol;
        data.status = 'Solved';
    else
        data.W = nan(n, comp);
        data.info = sol;
        data.status = 'Error';
    end
   
else
    error(['ftb:' mfilename],...
        'Unknown solver');
end

% Project W onto the signal+interference subspace
if isequal(cfg.eigenspace,'eig post')
    data.W = P*data.W;
end

end

