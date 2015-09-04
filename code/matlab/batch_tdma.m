epsilons = .05:.05:.4;
K = 12;
dir = 'sims/';
prefix = 'tdma_';
postfix = '.txt';
tx_tot = zeros(1,length(epsilons));
MC = 300;
for m = 1:MC
    for i = 1:length(epsilons)
        eps = epsilons(i);
        t = tdma_sim(K, eps);
        tx_tot(i) = tx_tot(i) + t;
        filename = [dir, prefix, num2str(K), '_', num2str(eps), postfix];
        dlmwrite(filename, [t], '-append');
    end
    
end

tx_tot = tx_tot./MC;

