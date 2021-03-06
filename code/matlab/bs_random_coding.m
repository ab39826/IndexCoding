function [TOTAL_TRANSMISSIONS] = bs_random_coding(K, eps_vec, verbose, dest)
%bs_random_coding Random coding for base station model
% Step 1: Uplink desired communication pairings (currently lossless)
% Step 2: Generate and send a single random symbol
% Step 3: Decode and update if possible
% Step 4: Go to Step 2
% Inputs:
%  K: number of nodes
%  eps_vec: either [min_eps, max_eps], [eps], or [eps_1, ..., eps_K]
%  of erasure probabilities
%  dest (optional): receiver i wants message dest(i)
% Outputs:
%  TOTAL_TRANSMISSIONS

if nargin < 4
    rand_dest = true;
else
    % user-supplied dest. size(dest,1) = K;
    rand_dest = false;
end

if nargin < 3
    verbose = 0;
end

% cvx_quiet(true);

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
if rand_dest
    if verbose
        disp('Message destinations chosen randomly');
    end
    dest = multirandperm(K, 1); % receiver i wants message dest(i)
end
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

error = false;
i = 1;
while any(isnan(final_messages))
    if TOTAL_TRANSMISSIONS > 600
        error = true;
        TOTAL_TRANSMISSIONS = -1;
        break;
    end
    Kprime = length(map);
    if verbose
        disp(['Remaining ', num2str(Kprime), ' nodes are: ']);
        disp(map(:)');
        disp('Interferer matrix is:');
        disp(J);
    end
    % special case for one remaining node
    if Kprime == 1
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        while ~transmit_messages(1, eps_vec(map))
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        end
        final_messages(map) = W(map);
    else
    
        % generate next symbol
%         L = length(tx_symbols);
%         if i == 1
%             L = 0;
%         end
        V = zeros(1,K);
        V(map) = randn(1,Kprime);
%         V = randn(1,K);
        tx_symbols(i) = Symbol(V, W, 1:K);
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