function [ X_hat ] = admira(r, b, m, n, iter, A, A_star)
%admira ADMiRA greedy low-rank matrix completion from "Efficient and
%Guaranteed Rank Minimization by Atomic Decomposition" - Lee and Bresler

if 2*r > min(m,n)
    r_prime = min(m,n);
else
    r_prime = 2*r;
end
% initialization
X_hat = randn(m,n); %zeros(m,n); % step 1
Psi_hatU = []; Psi_hatV = []; % step 2
for i=1:iter % step 3
    % step 4 - PCA
    Y = A_star(b-A(X_hat));
    [U S V] = svd(Y);
    Psi_primeU = U(:,1:r_prime);
    Psi_primeV = V(:,1:r_prime);
    % step 5 - 
    Psi_tildeU = [Psi_primeU Psi_hatU];
    Psi_tildeV = [Psi_primeV Psi_hatV];
    % step 6    
    AP = @(b) APsiUV(b,A,Psi_tildeU, Psi_tildeV);
    APt = @(s) APsitUV(s,A_star,Psi_tildeU, Psi_tildeV);
    ALS = @(b) APt(AP(b));
    [s, res, iter] = cgsolve(ALS, APt(b), 1e-6, 100, 0);
    X_tilde = Psi_tildeU*diag(s)*Psi_tildeV'; 
    % step 7
    [U S V] = svd(X_tilde);
    Psi_hatU = U(:,1:r);
    Psi_hatV = V(:,1:r);
    s = diag(S);
    % step 8
    X_hat = Psi_hatU*diag(s(1:r))*Psi_hatV';
end

end

