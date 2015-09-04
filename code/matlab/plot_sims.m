epsilons = .05:.05:.4;
K_vec = 4:4:32;

ic_markers = ['k--', 'r--', 'g--', 'b--'];

rc_markers = ['k-', 'r-', 'g-', 'b-'];

figure(1)
hold on;
for k = 1:4
    plot(epsilons, tdma_mean(2*k,:)./ic3_mean(2*k,:), ic_markers(k))
    plot(epsilons, tdma_mean(2*k,:)./rc2_mean(2*k,:), rc_markers(k))    
end

% plot(epsilons, ic3_mean([2:2:8],:),epsilons, tdma_mean([2:2:8],:))
% plot(epsilons, tdma_mean([2:2:8],:)./rc2_mean([2:2:8],:), epsilons, ones(size(epsilons)))
% hold;
% plot(epsilons, tdma_mean([2:2:8],:)./ic3_mean([2:2:8],:))
% legend('RC Gain K=8', 'RC Gain K=16', 'RC Gain K=24', 'RC Gain K=32', 'IC Gain K=8', 'IC Gain K=16', 'IC Gain K=24', 'IC Gain K=32')
% xlabel('Erasure Probability')
% ylabel('Gain')
% 
% figure(2)
% plot(K_vec, tdma_mean(:,[2:2:8])./ic3_mean(:,[2:2:8]), K_vec, ones(size(K_vec)))
% legend('Gain eps=.1', 'Gain eps=.2', 'Gain eps=.3', 'Gain eps=.3')
% xlabel('Number of Receivers, K')
% xlim([4 32])
% ylabel('Number of Transmissions')
    