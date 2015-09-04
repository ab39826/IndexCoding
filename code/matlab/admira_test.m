%%
clear; clc;
% define random problem setup
m = 10; n = 10; r = 6; eps = .4; p = m*n*(1-eps);

I = zeros(m,n);
interfidx = randsample(m*n, p);
I(interfidx) = 1;
diagidx = 1:1+m:m*m; % indices of diagonal
I(diagidx) = 0;
clear interfidx diagidx
% I = [0 0 0 1; ...
%      0 0 1 0; ...
%      1 1 0 0; ...
%      0 0 1 0];
%  [m n] = size(I);
% r = 2;

% generate idx from I
interfidx = find(I>0);
diagidx = 1:1+m:m*m; % indices of diagonal
idx = unique([interfidx' diagidx]);
X = zeros(m,n);
X(diagidx) = 1;
X(interfidx) = 0;

%%
% define A operator and adjoint A_star
[ix iy] = ind2sub([m n], idx);
A = @(X)  X(idx);
A_star = @(b) full(sparse(ix, iy, b, m, n));


%%
% parameters
iter = 100;
b = A(X);

X_hat = admira(r, b, m, n, iter, A, A_star)
disp(['rank of X_hat is ', num2str(rank(X_hat))])
disp(['sum of "nonzero" elements is ', num2str(sum(abs(X_hat(I>0))))]);
disp(['diagonals are:'])
disp(diag(X_hat));