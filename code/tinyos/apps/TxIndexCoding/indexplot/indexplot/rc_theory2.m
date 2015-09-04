K = 4;
epsilons = 0:.01:.5;
ic = zeros(length(epsilons),1);
for j=1:length(epsilons)
    eps = epsilons(j);
    rc(j) = K-1 + (K-1)*eps*phi_K(K, eps);
end

t = K./(1-epsilons');
hold;
plot(epsilons, t./rc, 'ro-')