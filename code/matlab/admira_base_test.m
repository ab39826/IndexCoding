clear; clc;
% define random problem setup
m = 100; n = 200; r = 5; p = round(n*m/2);
Yl = randn(m,r);
Yr = randn(n,r);
X = Yl*Yr';

% define A operator and adjoint A_star
idx = randperm(m*n); idx = idx(1:p);
[ix iy] = ind2sub(size(X), idx);
A = @(X)  X(idx);
A_star = @(b) full(sparse(ix, iy, b, m, n));

% parameters
iter = 5;
b = A(X);

X_hat = admira(r, b, m, n, iter, A, A_star);


SNR = 20*log10(norm(X,'fro')/norm(X-X_hat,'fro'))
% imshow(X-X_hat)
