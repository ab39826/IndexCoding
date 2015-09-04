%%
clear; clc
cvx_quiet(true);

K = 32;
W = randi(256, K, 1);
min_eps = .1; max_eps = .5;
eps_vec = min_eps + (max_eps - min_eps).*rand(1, K);
R = transmit_messages(W, eps_vec);
% R(logical(eye(size(R)))) = 0;
[A map] = update_antidotes(true, [], R, 1:K, W);

I = compute_interferers(A)
S = eye(length(map)) + I;
disp(['Number of nodes remaining: ', num2str(length(map))]);

%%
m = max(ceil(sum(S,2)'./(1-eps_vec(map))))
% [V U] = nuclear_NC_K_user(I, randn(m,length(map)), .1, 4, []);
[V U] = nuclear_alignment(I,m,.1);
% V = rand(m,length(map));
% m=12;
% [V U] = nuclear_NC_K_user(I,randn(m,K),.1,1,[]);
% X = U'*V
% X = randn(size(I));
% X(logical(eye(size(X)))) = 1;
% X(I==1) = 0;

[Vg Ug] = greedy_alignment(I,1e-4,25,1);
m2 = size(Vg,1)

%%
sym_vals = zeros(1,m);
for i = 1:m
    s = Symbol(V(i,:), W(map), map);
    sym_vals(i) = s.val;
end

R2 = transmit_messages(sym_vals, eps_vec(map));
%%
R2 = zeros(size(R2));
for i=1:size(R2,1)
    r = randperm(m);
    R2(i,r(1:m2)) = 1;
end
%%
disp(sprintf('k\tTruth\tDecoded'));
for k = 1:length(map)
    Vk_rec = V(logical(R2(k,:)),:);
    if size(Vk_rec,1) > 0
        Vk_null = Vk_rec(:,logical(I(k,:)));
        if size(Vk_null,1) == 0
            u = ones(size(Vk_rec,1),1);
        else
            u = nullvec(Vk_null');
        end
        if size(u,1) > 0
            x = u'*Vk_rec;
            Wk = (u'*Vk_rec*W(map) - u'*Vk_rec*A(k,:)')/x(k);
        else
            Wk = 'ERROR';
        end
    else
        Wk = 'ERROR';
    end
%     disp(['Message ', num2str(k), ': Truth: ', num2str(W(k)), ' Decoded: ', num2str(Wk)]);
    disp(sprintf('%d\t%d\t\t%s', k, W(map(k)), num2str(Wk)));
end

disp(['Total transmissions: ', num2str(K+m), ' TDMA (avg): ', num2str(sum(ceil(1./(1-eps_vec))))]);



% [V U] = greedy_alignment(I,1e-5,100,1);
% X = U'*V;

