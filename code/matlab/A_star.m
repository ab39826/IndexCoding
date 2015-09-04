function [ X ] = A_star(b, A, dim)
X = zeros(dim);
X(A) = b;
end