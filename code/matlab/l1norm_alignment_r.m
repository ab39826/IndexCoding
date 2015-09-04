function [V U] = l1norm_alignment_r(I, r, epsilon, iter)
%norm_alignment_r l1 norm interference alignment for target rank (number
%of transmissions) equal to r


% obtain problem parameters
[L K] = size(I);
U = randn(r,K);
% I = logical(I);


for i = 1:2*iter % 2 turns at each iteration
    cvx_begin
    if mod(i,2) == 1 % at odd turns, we optimze over the beamformers
        clear V f_cost
        variable V(r,K) 
    else % at even turns, we optimze over the zeroforcers
        clear U f_cost
        variable U(r,L)
    end
    
    
    f_cost = cvx(0); % initialize cost function
    for k = 1:L
        Vk_null = full(V(:,I(k,:)>0));
        if size(Vk_null,2) > 0
            f_cost = f_cost + norm(U(:,k)'*Vk_null,1); %each term is one interference block
        end
    end
    
    minimize f_cost
    subject to
    for k = 1:L
        U(:,k)'*V(:,k) >= epsilon
    end
    
    cvx_end
    
end

V = full(V);
U = full(U);
end



