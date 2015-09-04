function [perm] = singlerandperm(K)
%singlerandperm "random" permutation
% For each element (receiver), assign an index (message) that differs from the element
% Inputs:
%  K - number of elements
% Outputs:
%  perm [1-by-K]




perm = randperm(K);
range = 1:K;
reorder = range(perm == range); % these indices were assigned to themselves 
for i = 1:2:length(reorder)
    if i == length(reorder)
        % length was odd. reorder last element with index mod(i, K) + 1
        ind = mod(i, K) + 1;
        perm(reorder(i)) = perm(ind);
        perm(ind) = reorder(i);
    else
        % switch the two elements
        perm(reorder(i)) = reorder(i+1);
        perm(reorder(i+1)) = reorder(i);
    end
end
end



