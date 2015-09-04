clear; clc

epsilons = .05:.05:.4;
K_vec = [20:4:32];
MC = 600;

for k = 1:length(K_vec)
    K = K_vec(k);
    batch_simulation('rc2', K, 'rc2', epsilons, MC );
end