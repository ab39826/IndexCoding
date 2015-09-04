function [TOTAL_TRANSMISSIONS] = bs_random_index_coding(K, eps_vec, verbose)


if nargin < 3
    verbose = 0;
end

cvx_quiet(true);

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
    disp(' ');
    disp(['Number of receivers/nodes: ', num2str(K)]);
    disp(['Erasure probs. min: ', num2str(min(eps_vec)), ' max: ', num2str(max(eps_vec))]);
    disp('------');
end

% generate random messages
W = randi(256, K, 1);

% store final received messages. goal is to "de-NaN" by the end
final_messages = nan*zeros(K, 1);

% keep track of all transmitted and received messages/symbols
tx_symbols(1) = Symbol(nan, nan, nan); % [1 -by- # of transmissions]
% rx_symbols = zeros(K); % starts out as [K -by- # of transmissions], but loses rows over time

% keep track of number of transmissions
TOTAL_TRANSMISSIONS = 0;

%% Base Station - to - cellular model
% Uplink is assumed perfect, i.e. the BS has access to all messages and
% their destinations
dest = multirandperm(K, 1); % receiver i wants message dest(i)
A = diag(W); % receiver (row) i has access to the message it plans to send
mat_dest = sub2ind(size(A), 1:K, dest);
signal_space = false(K);
signal_space(mat_dest) = true;
I = compute_interferers(A, signal_space);
J = double(I);
J(mat_dest) = -1;
map = 1:K;

if verbose
    disp('Interferer matrix is:');
    disp(J);
end


%% Generate m symbols (linear combinations)
[V U] = alignment('mixed', J, nan, 1e-4, 100, verbose);
m = size(V,1);
if verbose
    disp(['Minimum rank is ', num2str(m)]);
end
% L = length(tx_symbols);
% for i = 1:m
%     tx_symbols(i) = Symbol(V(i,:), W, 1:K);
% end


%%
i = 1;

while any(isnan(final_messages))
    %%
    Kprime = length(map);
    if verbose
        disp(['Remaining ', num2str(Kprime), ' nodes are: ']);
        disp(map(:)');
%         disp('Interferer matrix is:');
%         disp(J);
    end
    
    %% special case for one remaining node
    if Kprime == 1
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        while ~transmit_messages(1, eps_vec(map))
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        end
        final_messages(map) = W(map);
    else
        %%
        % generate next symbol
        L = length(tx_symbols);
        if i > L
            tx_symbols(L+1:K) = Symbol(nan, nan, nan);
        end

        random_coeffs = randn(1,m);
        tx_symbols(i) = Symbol(random_coeffs*V, W, 1:K);
        R = transmit_messages(1, eps_vec(map));
        if i == 1
            rx_symbols = R;
        else
            rx_symbols = [rx_symbols R];
        end

        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        if verbose
            disp(['Transmission ', num2str(i)]);
            disp([' k  #']);
            disp([map(:) sum(rx_symbols,2)]);
        end

        % Solve for messages if possible
        [unsolved final_messages] = bs_decode_messages(dest, Kprime, map, ...
                rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose);
    
        %% update data structures
        J_old = J;
        map = find(isnan(final_messages));
    %     dest = dest(unsolved);
        rx_symbols = rx_symbols(unsolved,:);
        J = J(unsolved,:);
        I = I(unsolved,:);
        A = A(unsolved,:);

    end
    i = i + 1;
end

if verbose
    disp(['Total number of transmissions: ', num2str(TOTAL_TRANSMISSIONS)]);
end

end