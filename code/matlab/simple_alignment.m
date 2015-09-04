function [V U] = simple_alignment(m, J )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


[L K] = size(J);
V = zeros(m,K);
for k = 1:L
    Vk_null = V(:, J(k,:) > 0);
    if size(Vk_null,2) > 1
        Vk_null = [1; k]*ones(1,size(Vk_null,2));
        V(:, J(k,:) > 0) = Vk_null;
    end
end


Vk_rand = V(V==0);
Vk_rand = randn(size(Vk_rand));
V(V==0) = Vk_rand;

U = generate_U(V,J)
    
end

