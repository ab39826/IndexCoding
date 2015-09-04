function [inds] = multirandperm(K, n, all)
%multirandperm "random" permutation
% For each element (receiver), assign n indices (messages) that differ from the element
% Inputs:
%  K - number of elements
%  n - number of indices per element
%  all - true/false specifying whether each element is used as an index
%   (i.e. without replacement)
% Outputs:
%  inds [n-by-K]


inds = zeros(n,K);
for i = 1:n
    inds(i,:) = singlerandperm(K);
end
