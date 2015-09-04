clear; clc

K = 16;
W = randi(256, K, 1);
min_eps = .1; max_eps = 1;
eps_vec = min_eps + (max_eps - min_eps).*rand(1, K);
R = transmit_messages(W, eps_vec);
% R(logical(eye(size(R)))) = 0;
[A map] = update_antidotes(true, [], R, 1:K, W);

I = compute_interferers(A)
S = eye(length(map)) + I;
size(I,1)

%%
[Vg Ug] = greedy_alignment(I, 1e-4, 100, 1);
m = size(Vg,1);
%%
L = length(map);
I = logical(I);
V = randn(size(Vg));
% for k = 1:L
%     Vk_null = Vg(:,I(k,:));
%     [a b c] = svd(Vk_null');
%     b
%     size(Vk_null')
%     nullvec(Vk_null')
% end
V_final = zeros(size(V));
k=1; Vk_null = V(:,I(k,:));
[a b c] = svd(Vk_null);
Vk = a(:,1:5)*b(1:5,1:5)*c(:,1:5)';

