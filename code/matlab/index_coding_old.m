% index_coding.m

clear all; clc;
cvx_quiet(true);
%% Parameters
num_nodes = 16;
max_eps = 1;
min_eps = .1;
% num_msgs = 2;
num_msgs = 1;
%
epsilon = 1e-5;
% erasure probabilities for each node assumed static
eps_vec = min_eps + (max_eps - min_eps).*rand(1, num_nodes);
eps_vec = .5*ones(1,num_nodes);

disp(' ');
disp(['Number of receivers/nodes: ', num2str(num_nodes)]);
disp('------');
disp('Erasure probs. are: ')
disp(eps_vec);

% generate random messages. Elements in col k are messages desired by node k
msg_matrix = randi(256, num_msgs, num_nodes);

% store final received messages. goal is to "de-NaN" by the end
final_messages = nan*zeros(num_nodes, num_msgs);

%% Round Robin to start
disp('TDMA round. Received messages per receiver are:');
msg_vec = msg_matrix(1,:)';	% first round of messages
R = transmit_messages(msg_vec, eps_vec);
disp(R);


% [final_messages antidotes map] = update_final_messages(final_messages, nan, 1:num_nodes, R, msg_vec);

[antidotes, map] = update_antidotes(true, [], R, 1:num_nodes, msg_vec);
final_messages(diag(R) == 1) = msg_vec(diag(R) == 1);


disp('Remaining receivers are: ');
disp(map);

I = compute_interferers(antidotes);

disp('Interferer matrix is:');
disp(I);

%% Generate next m transmissions
K = length(map);

% m = K-1; %ceil(K/2);
% [V U] = nuclear_NC_K_user(I, randn(m,K), .1, 3, []);
% V = norm_vec(full(V));
% U = norm_vec(full(U));
[V U] = greedy_alignment(I, epsilon, 100, 1);
m = size(U,1)
X = U'*V;
% sum(X(I>0))
% diag(X)
sym_vals = zeros(1,m);
msg_vec = [msg_vec; zeros(m,1)];
for i = 1:m
    s(i) = Symbol(V(i,:), U(i,:), msg_vec(map), map);
    sym_vals(i) = s(i).val;
    msg_vec(num_nodes+i) = s(i).val;
end

R2 = transmit_messages(sym_vals, eps_vec(map));

%% Solve any if possible
disp(sprintf('k\tTruth\tDecoded'));
decoded = zeros(1,length(map));
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
            Wk = (u'*Vk_rec*msg_vec(map) - u'*Vk_rec*antidotes(k,:)')/x(k);
            final_messages(map(k)) = Wk;
            decoded(k) = 1;
        else
            Wk = 'ERROR';
        end
    else
        Wk = 'ERROR';
    end
%     disp(['Message ', num2str(k), ': Truth: ', num2str(W(k)), ' Decoded: ', num2str(Wk)]);
    disp(sprintf('%d\t%d\t\t%s', k, msg_vec(map(k)), num2str(Wk)));
end

[new_antidotes, map] = update_antidotes(false, antidotes, R2, map, msg_vec, decoded);
I2 = compute_interferers(new_antidotes);

% [final_messages antidotes map] = update_final_messages(final_messages, map, R, msg_vec);


%% Generate next m transmissions

[i j] = find(new_antidotes(:,length(map)+1:end)~=0);
j2 = j+length(map);
Omega = [i j2];
K2 = size(I2,2);
m2 = length(map)-1; %ceil(3*m/4);
% [V2 U2] = nuclear_NC_K_user(I2, randn(m2,K2), .1, 6,Omega);
% V2 = norm_vec(full(V2));
% U2 = norm_vec(full(U2));
x
m2 = size(U2,1)
X2 = U2'*V2;
% sum(X2(I2>0))
% diag(X2)
%%
sym_vals2 = zeros(1,m2);
msg_vec2 = [msg_vec; zeros(m2,1)];
map2 = [map num_nodes+1:m+num_nodes];
for i = 1:m2
    s2(i) = Symbol(V2(i,:), U2(i,:), msg_vec2(map2), map2);
    sym_vals2(i) = s2(i).val;
    msg_vec2(end-m2+i) = s2(i).val;
end

R3 = transmit_messages(sym_vals2, eps_vec(map));




