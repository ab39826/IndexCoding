% index_coding.m

clear all; clc;

cvx_quiet(true);

%% Setup
% Parameters
K = 8; % number of nodes

min_eps = .9; max_eps = .9; % erasure probability bounds
% erasure probabilities for each node assumed static
eps_vec = min_eps + (max_eps - min_eps).*rand(1, K);

num_iter = 1; % # of iterations for nuclear alignment
%

disp(' ');
disp(['Number of receivers/nodes: ', num2str(K)]);
disp(['Erasure probs. min: ', num2str(min(eps_vec)), ' max: ', num2str(max(eps_vec))]);
disp('------');

% generate random messages. Elements in col k are messages desired by node k
W = randi(256, K, 1);

% store final received messages. goal is to "de-NaN" by the end
final_messages = nan*zeros(K, 1);

% keep track of number of transmissions
TOTAL_TRANSMISSIONS = 0;

%% Round Robin to start
disp('TDMA round. Received messages per receiver are:');
R = transmit_messages(length(W), eps_vec);
TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + K;
% disp(R);

% update antidotes and fill in received messages in final_messages
[A, map] = update_antidotes(true, [], R, 1:K, W);
final_messages(diag(R) == 1) = W(diag(R) == 1);

disp(['Remaining ', num2str(length(map)), ' nodes are: ']);
disp(map);

I = compute_interferers(A);
disp('Interferer matrix is:');
disp(I);

%%
while any(isnan(final_messages))
    Kprime = length(map);
    disp(['Remaining ', num2str(Kprime), ' nodes are: ']);
    disp(map);
    
    % special case for one remaining node
    if Kprime == 1
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        while ~transmit_messages(length(W(map)), eps_vec(map))
            TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
        end
        final_messages(map) = W(map);
    else
        % Generate next m transmissions
        % first run greedy alignment to get m_hat quickly
        [Vg Ug] = alignment('greedy', I, nan, 1e-4, 20, 0);
        m_hat = size(Vg,1);

        % next choose m accordingly
        m = ceil(m_hat/(1-max(eps_vec(map))));
        disp(['Minimum rank is ', num2str(m_hat), ', number of transmissions is ', num2str(m)]);

        % next run nuclear alignment
        [V U] = alignment('nuclear', I, m, nan, num_iter, 1);
        m = size(V,1); % reassign in case of trivial answer
        
        % generate next m symbols based on V
        sym_vals = zeros(1,m);
        S(1:m) = Symbol([nan], [nan], nan);
        for i = 1:m
            S(i) = Symbol(V(i,:), W(map), map);
            sym_vals(i) = S(i).val;
        end

        R2 = transmit_messages(length(sym_vals), eps_vec(map));
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + m;

        %% Solve for messages if possible
        unsolved = false(1,Kprime);
        disp(sprintf('k\tTruth\tDecoded'));
        for k = 1:Kprime
            Wk = decode_message(I(k,:), S(R2(k,:) == 1), A(k,:), k);

            if ~strcmp(Wk, 'ERROR')
                final_messages(map(k)) = Wk;
            else
                unsolved(k) = 1;
            end

            % this way is cheating; Wk may not match truth but nevertheless be
            % decoded as such
            %     if Wk == W(map(k))
            %         final_messages(map(k)) = Wk;
            %     end
            disp(sprintf('%d\t%d\t\t%s', k, W(map(k)), num2str(Wk)))
        end
        
        map = find(isnan(final_messages));
        A = A(unsolved,unsolved);
        I = I(unsolved, unsolved);    
    end
end

disp(['Total number of transmissions: ', num2str(TOTAL_TRANSMISSIONS)]);
