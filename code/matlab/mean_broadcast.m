function totsum = mean_broadcast(K, eps)
totsum = 0;
inds = zeros(1,K);

for i = 1:2^K-1
    for j = 1:K
        inds(j) = bitsra(bitand(i,2^(j-1)),j-1);
    end
    isum = sum(inds);
    totsum = totsum + (-1)^(isum-1)/(1 - eps^isum);
end
end