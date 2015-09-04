function [ X ] = nuclear_test(I, iter)

K = size(I,1);

% for i = 1:iter
        
    cvx_begin
        variable X(K,K) 

    
    
    
%     %%% the following defines the cost function %%%
%     J = cvx(zeros(K, K)); %initialize the interference matrix
%     f_cost = cvx(0); % initialize cost function
%     for k = 1:K
%         Ik = nonzeros([1:K].*I(k,:))'; % transform the interference indicators to index sets
%         for l = 1:length(Ik)
%             J(k,l) = U(:,k)'*V(:,Ik(l)); %each term is one interference block
%         end
%         if length(Ik) > 0
%             f_cost = f_cost + sum(abs(J(k,:))); % the cost function is the sum of interference singular values
% %             f_cost = f_cost + norm_nuc(J(k,:)); % the cost function is the sum of interference singular values
%         end
%     end
%     if mod(i,2) == 1
%         f_cost = f_cost + lambda*norm(V,1);
%     else
%         f_cost = f_cost + lambda*norm(U,1);
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% nuclear norm minimization %%%%%%%%%%%
    f_cost = norm_nuc(X);
    minimize f_cost
    subject to
    diag(X) == 0;
    X(I>0) == 1;
%     ind = zeros(K);
%     ind(randi(K*K,1,20)) = randn(1,20);
%     ind(logical(eye(size(ind)))) = 0;
%     X(ind~=0) == ind(ind~=0);
    %     for k = 1:K
%         U(:,k)'*V(:,k) == semidefinite(1) 
%         U(:,k)'*V(:,k) >= epsilon % minimum eigenvalue constraint
        % nonnegative definite constraint 
        % (not needed, cvx automatically sets S_k to NND due to the lambda_min constraint)
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cvx_end
    
% end

end

