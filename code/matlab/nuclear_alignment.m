function [V U] = nuclear_alignment(I, m, epsilon, iter, verbose)
%nuclear_alignment_r nuclear norm interference alignment for number of
%transmissions equal to m

if nargin < 5
    verbose = 0;
end

% get parameters
% L - number of nodes
% K - number of messages/symbols

[L K] = size(I);
U = randn(m,L);
% I = logical(I);

if verbose
    disp(['Nuclear Alignment (', num2str(iter), ') iterations']);
end


for i=1:2*iter
cvx_begin

    if mod(i,2) == 1
        clear V f_cost
        variable V(m,K)
        if verbose
            disp(['  Iteration ', num2str(round(i/2))]);
        end
    else
        clear U f_cost
        variable U(m,L)
    end
    f_cost = cvx(0);
    for k = 1:L
        Vk_null = full(V(:,I(k,:)>0));
        if size(Vk_null,2) > 0
            if mod(i,2) == 1
                f_cost = f_cost + norm_nuc(Vk_null);
            else
                f_cost = f_cost + norm_nuc(U(:,k)'*Vk_null);
            end
        end
        
    end

    minimize f_cost
    subject to
    for k = 1:L
        l = find(I(k,:) == -1);
        U(:,k)'*V(:,l) >= epsilon;
    end

cvx_end
V = full(V);
U = full(U);
end

if verbose
    disp('Done');
end

end





