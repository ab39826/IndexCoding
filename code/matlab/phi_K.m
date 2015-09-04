function [g] = phi_K(K, eps)
% K = 8;
% epsilons = 0:.01:.5;
a = dec2bin(1:2^K - 1);
b = zeros(size(a));
for i=1:length(a(:))
    b(i) = str2num(a(i));
end
% ic = zeros(length(epsilons),1);
% for j=1:length(epsilons)
%     eps = epsilons(j);
    g = 0;
    for i=1:2^K-1
        g = g + (-1)^(sum(b(i,:)) - 1) / (1 - eps.^(sum(b(i,:))));
    end
%     ic(j) = g;
% end

% t = K./(1-epsilons');
% plot(epsilons, t./ic, 'bo-')