function [TOTAL_TRANSMISSIONS] = random_coding_sim(K, eps_vec, verbose)
%random_coding_sim Run random coding WITHOUT TDMA round
% Inputs:
%  K: number of nodes
%  eps_vec: either [min_eps, max_eps], [eps], or [eps_1, ..., eps_K]
%  of erasure probabilities
% Outputs:
%  TOTAL_TRANSMISSIONS

if nargin < 3
    verbose = 0;
end


%% Setup

% erasure probabilities for each node assumed static
if length(eps_vec) < K
    min_eps = eps_vec(1);
    max_eps = eps_vec(end);
    eps_vec = min_eps + (max_eps - min_eps).*rand(1, K);
end

% num_iter = 1; % # of iterations for nuclear alignment
%

if verbose
    disp(' -------------------------------------- ');
    disp(' -------------------------------------- ');
    disp(['Number of receivers/nodes: ', num2str(K)]);
    disp(['Erasure probs. min: ', num2str(min(eps_vec)), ' max: ', num2str(max(eps_vec))]);
    disp('------');
end

% generate random messages. Elements in col k are messages desired by node k
W = randi(256, K, 1);

% store final received messages. goal is to "de-NaN" by the end
final_messages = nan*zeros(K, 1);

% keep track of all transmitted and received messages/symbols
tx_symbols(1:K) = Symbol(nan, nan, nan); % [1 -by- # of transmissions]
% rx_symbols = zeros(K); % starts out as [K -by- # of transmissions], but loses rows over time

% keep track of number of transmissions
TOTAL_TRANSMISSIONS = 0;


% %% No round robin, but too lazy to change the code
% % just set R initially to zeros
% if verbose
%     disp('TDMA round.');
% end
% 
% for k = 1:K
%     tx_symbols(k) = Symbol(1, W(k), 1);
% end
% % R = transmit_messages(K, eps_vec);
% R = zeros(K);
% % disp(R);
% 
% % TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + K;
% 
% % update antidotes and fill in received messages in final_messages
% [A, map] = update_antidotes(true, [], R, 1:K, W);
% final_messages(diag(R) == 1) = W(diag(R) == 1);
% rx_symbols = R(map,map);
% % transform remaining tx_symbols to full-fledged symbol vectors
% tx_symbols = tx_symbols(map);
% E = eye(length(map));
% for i = 1:length(tx_symbols)
%     tx_symbols(i) = Symbol(E(i,:), E(i,:)*tx_symbols(i).val, map);
% end

% disp(['Remaining ', num2str(length(map)), ' nodes are: ']);
% disp(map);
% 
% I = compute_interferers(A, logical(eye(size(A))));
% J = double(I);
% J(logical(eye(size(J)))) = -1;
% new_K = length(map);

% disp('Interferer matrix is:');
% disp(I);

%%
I = true(K);
I(logical(eye(K))) = 0;
J = ones(K);
J(logical(eye(K))) = -1;
map = 1:K;
A = zeros(K);


i = 1;
while any(isnan(final_messages))
    Kprime = length(map);
    % special case for one remaining node
    if Kprime == 1
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        while ~transmit_messages(1, eps_vec(map))
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        end
        final_messages(map) = W(map);
    else
    
        % generate next symbol
        L = length(tx_symbols);
        if i > L
            tx_symbols(L+1:K) = Symbol(nan, nan, nan);
        end
        V = zeros(1,K);
        V(map) = randn(1,Kprime);
%         V = randn(1,K);
        tx_symbols(i) = Symbol(V, W, 1:K);
        R2 = transmit_messages(1, eps_vec(map));
        if i == 1
            rx_symbols = R2;
        else
            rx_symbols = [rx_symbols R2];
        end

        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        if verbose
            disp(['Transmission ', num2str(i)]);
            disp([' k  #']);
            disp([map(:) sum(rx_symbols,2)]);
        end

        % Solve for messages if possible
        [unsolved final_messages] = decode_messages(nan, Kprime, map, ...
            rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose);

        % update data structures
        J_old = J;

    %     A = ones(length(map),1)*[tx_symbols(1:L).val].*rx_symbols;
    %     I = compute_interferers(A, J_old < 0);

    %     J = double(I);
    %     J(J_old < 0) = -1;

        map = find(isnan(final_messages));
        rx_symbols = rx_symbols(unsolved,:);
        J = J(unsolved,:);
        I = I(unsolved,:);
        A = A(unsolved,:);
        i = i + 1;
    end
end

if verbose
    disp(['Total number of transmissions: ', num2str(TOTAL_TRANSMISSIONS)]);
end
end