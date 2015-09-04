function [TOTAL_TRANSMISSIONS] = index_coding_sim4(K, eps_vec, verbose)
%index_coding_sim4 Run index coding 4th version
% Step 1: TDMA
% Step 2: Generate m = minrank symbols
% Step 3: Send a single symbol
% Step 4: Decode and update if possible
% Step 5: Go to Step 2
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


%% Round Robin to start
if verbose
    disp('TDMA round.');
end

for k = 1:K
    tx_symbols(k) = Symbol(1, W(k), 1);
end
R = transmit_messages(K, eps_vec);
% disp(R);

TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + K;

% update antidotes and fill in received messages in final_messages
[A, map] = update_antidotes(true, [], R, 1:K, W);
final_messages(diag(R) == 1) = W(diag(R) == 1);
rx_symbols = R(map,map);
% transform remaining tx_symbols to full-fledged symbol vectors
tx_symbols = tx_symbols(map);
E = eye(length(map));
for i = 1:length(tx_symbols)
    tx_symbols(i) = Symbol(E(i,:), E(i,:)*tx_symbols(i).val, map);
end

% disp(['Remaining ', num2str(length(map)), ' nodes are: ']);
% disp(map);

I = compute_interferers(A, logical(eye(size(A))));
J = double(I);
J(logical(eye(size(J)))) = -1;
new_K = length(map);

% disp('Interferer matrix is:');
% disp(I);

%%
while any(isnan(final_messages))
    %%
    Kprime = length(map);
    if verbose
        disp(['Remaining ', num2str(Kprime), ' nodes are: ']);
        disp(map(:)');
        disp('Interferer matrix is:');
        disp(J);
    end
    
    %% special case for one remaining node
    if Kprime == 1
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        while ~transmit_messages(1, eps_vec(map))
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        end
        final_messages(map) = W(map);
    else
        %% Generate next m transmissions
%         [V U] = alignment('mixed', J, nan, 1e-4, 100, 1);
        [V U] = alignment('mixed', J, nan, 1e-4, 100, 0);
        m = size(V,1);
%         mg = size(Vg,1);
        
        if verbose
            disp(['Minimum rank is ', num2str(m)]);
%             disp(['(Greedy rank is ', num2str(mg), ')']);
        end
        
        % generate next symbol based on current V
%         sym_vals = zeros(1,m);
        L = length(tx_symbols);
%         unsolved = true(1,Kprime);
        m_i = 0;
%         while all(unsolved) && m_i < m
            m_i = m_i + 1;
            tx_symbols(L+m_i) = Symbol(nan, nan, nan);
            tx_symbols(L+m_i) = Symbol(V(m_i,:), [tx_symbols(1:end-m_i).val], map);
            R2 = transmit_messages(1, eps_vec(map));
            if verbose
                disp(['Transmission ', num2str(m_i), '/', num2str(m)]);
                disp(R2);
            end
        
        
%         tx_symbols(L+1:L+m) = Symbol(nan, nan, nan);
%         for i = 1:m
%             if size(V(i,:),2) ~= size([tx_symbols(1:end-m).val],2)
%                 err = MException('IndexCoding2:SizeMismatch', ...
%                     'V and tx_symbols do not match in size');
%                 throw(err)
%             end
%             tx_symbols(L+i) = Symbol(V(i,:), [tx_symbols(1:end-m).val], map);
% %             sym_vals(i) = tx_symbols(L+i).val;
%         end
% 
%         R2 = transmit_messages(m, eps_vec(map));
%         if verbose
%             disp(['Index Coding Round. Received messages per receiver are:']);
%             disp(R2);
%         end
            rx_symbols = [rx_symbols R2];
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;


            %% Solve for messages if possible
            [unsolved final_messages] = decode_messages(new_K, Kprime, map, ...
                rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose);
%             unsolved
%         end
        %% update data structures
        J_old = J;
        
        A = ones(length(map),1)*[tx_symbols.val].*rx_symbols;
        I = compute_interferers(A, J_old < 0);
                
        J = double(I);
        J(J_old < 0) = -1;
        
        map = find(isnan(final_messages));
        rx_symbols = rx_symbols(unsolved,:);
        J = J(unsolved,:);
        I = I(unsolved,:);
        A = A(unsolved,:);
        
        for i = 1:length(tx_symbols)
            tx_symbols(i).v_coeffs = [tx_symbols(i).v_coeffs zeros(1,m_i)];
%             tx_symbols(i).msg_inds = [tx_symbols(i).msg_inds zeros(1,m)];
        end
        
    end
end

if verbose
    disp(['Total number of transmissions: ', num2str(TOTAL_TRANSMISSIONS)]);
end
end