function [B] = normalize_vec(A)
% Column-wise vector norm on n-by-m matrix A
B = zeros(size(A));
for i=1:size(A,2)
    B(:,i) = A(:,i)/norm(A(:,i));
end
B(isnan(B)) = 0;
end

