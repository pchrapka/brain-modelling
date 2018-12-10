function P = eig_projection(cfg)
%EIG_PROJECTION Calculates eigenspace projector
%   EIG_PROJECTION(CFG) returns the eigenspace projector
%   
%   Input
%   cfg.R   covariance matrix of data [channels x channels]
%       n_interfering_sources
%                   number of interfering sources

% Decompose the covariance matrix
[V,D] = eig(cfg.R);
% Sort eigenvalues from smallest to largest
[~,permutation]=sort(diag(D));
% Reorder the eigenvalues
D = D(permutation,permutation);
% Reorder the eigenvectors
V = V(:,permutation);
% Take the largest J+1 eigenvectors
k = cfg.n_interfering_sources+1;
E = V(:,end-k+1:end);
% Flip the matrix left to right so the eigenvector associated with
% the largest eigenvalues is on the left
E = fliplr(E);

% Calculate the projection matrix
P = E*(E');

end