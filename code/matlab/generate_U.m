function [ U ] = generate_U( V, J )
%generate_U Generate zero-forcing matrix from V and J
[L K] = size(J);
[m K] = size(V);

U = zeros(m, L);
for l = 1:L
    U(:,l) = nullvec(V(:,J(l,:) > 0)');
end

end

