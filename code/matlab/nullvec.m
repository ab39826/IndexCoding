function [ z ] = nullvec(X, tol)
%null_vec Returns a vector z in the nullspace of X via SVD, where values
%under tol are considered zero. Returns [] if no such vector z exists

if nargin < 2
    tol = 1e-5;
end

[U S V] = svd(X);
if size(S,2) > size(S,1)
    z = V(:,end);
else
    if size(S,2) > 1
        s = diag(S) < tol;
    else
        s = S(1) < tol;
    end
    if any(s)
        z = V(:,s);
%         z = z(:,end);
    else
        z = [];
    end
end

end

