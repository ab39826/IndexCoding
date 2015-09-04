epsilons = .05:.05:.5;
K_vec = 4:4:8;

% dir = 'sims/';
dir = 'TheseusSims1k/';
postfix = '.txt';
ic3_prefix = 'bsic';
tdma_prefix = 'tdma';
rc2_prefix = 'bsrc';


ic3_mean = zeros(length(K_vec),length(epsilons));
tdma_mean = zeros(length(K_vec),length(epsilons));
ic3_std = zeros(length(K_vec),length(epsilons));
tdma_std = zeros(length(K_vec),length(epsilons));
rc2_mean = zeros(length(K_vec),length(epsilons));
rc2_std = zeros(length(K_vec),length(epsilons));

for k = 1:length(K_vec)
    K = K_vec(k);
    for i = 1:length(epsilons)
        eps = epsilons(i);
    %     ic_filename = [dir, ic_prefix ,'_', num2str(K), '_', num2str(eps), postfix];
        ic3_filename = [dir, ic3_prefix ,'_', num2str(K), '_', num2str(eps), postfix];
        tdma_filename = [dir, tdma_prefix, '_', num2str(K), '_', num2str(eps), postfix];
        rc2_filename = [dir, rc2_prefix, '_', num2str(K), '_', num2str(eps), postfix];

    %     ic_data = dlmread(ic_filename);
    %     ic_mean(i) = mean(ic_data);
    %     ic_std(i) = std(ic_data);

        ic3_data = dlmread(ic3_filename);
        ic3_mean(k,i) = mean(ic3_data);
        ic3_std(k,i) = std(ic3_data);

        tdma_data = dlmread(tdma_filename);
        tdma_mean(k,i) = mean(tdma_data);
        tdma_std(k,i) = std(tdma_data);

        rc2_data = dlmread(rc2_filename);
        rc2_mean(k,i) = mean(rc2_data);
        rc2_std(k,i) = std(rc2_data);
    end
end

 hold on;
 plot(epsilons, tdma_mean(1,:)./ic3_mean(1,:), 'bo-',epsilons, tdma_mean(2,:)./ic3_mean(2,:), 'bx--')
 hold on;
 plot(epsilons, tdma_mean(1,:)./rc2_mean(1,:), 'ro-',epsilons, tdma_mean(2,:)./rc2_mean(2,:), 'rx--')
 xlabel('Prob. of erasure')
 ylabel('# transmissions')
 legend('Index Coding (4)', 'Index Coding (8)', 'Random Coding (4)', 'Random Coding (8)');
%  title(['K = ', num2str(K)]);
 hold off;
