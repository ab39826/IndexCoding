clear; clc
epsilons = .05:.05:.4;
K_vec = [4:4:8];
MC = 3;
ic_prefix = 'bsic'; %ics for TDM+index_coding_sim_simple
tdma_prefix = 'tdma';
rc_prefix = 'bsrc'; %rc2 for TDM+RNC

for m = 1:MC
    for k = 1:length(K_vec)
        K = K_vec(k)
        dest = reshape([2:2:K; 1:2:K], 1, []);
        batch_simulation('rc2', K, rc_prefix, epsilons, 1);
        batch_simulation('ics', K, ic_prefix, epsilons, 1);
        batch_simulation('bsrc', K, rc_prefix, epsilons, 1, dest);
        batch_simulation('tdma', K, tdma_prefix, epsilons, 1);
    end
end
