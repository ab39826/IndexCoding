function [V U] = greedy_alignment_r(I, r, iter)
%greedy_alignment_r greedy interference alignment for target rank (number
%of transmissions) equal to r

% obtain parameters
[m n] = size(I);

% generate index set idx from I
interfidx = find(I>0);
% diagidx = 1:1+m:m*m; % indices of diagonal
diagidx = find(I<0);
idx = unique([interfidx' diagidx']);
% generate target matrix X
X = zeros(m,n);
X(diagidx) = 1;
X(interfidx) = 0;

% define A operator and adjoint A_star
[ix iy] = ind2sub([m n], idx);
A = @(X)  X(idx);
A_star = @(b) full(sparse(ix, iy, b, m, n));

b = A(X); % sampling operator
         
X_hat = admira(r, b, m, n, iter, A, A_star);

% decompose X_hat into zero-forcing matrices
[U_full S_full V_full] = svd(X_hat);
s = diag(S_full);
% arbitrarily embed singular values  in U
% transpose is to maintain consistency with nuclear_alignment
U = transpose(U_full(:,1:r)*diag(s(1:r)));
V = transpose(V_full(:,1:r));
end
