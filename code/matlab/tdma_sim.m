function [TOTAL_TRANSMISSIONS] = tdma_sim(K, eps_vec, verbose)
%tdma_sim Run TDMA simulation
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

if verbose
    disp(' ');
    disp(['Number of receivers/nodes: ', num2str(K)]);
    disp(['Erasure probs. min: ', num2str(min(eps_vec)), ' max: ', num2str(max(eps_vec))]);
    disp('------');
end

% generate random messages. Elements in col k are messages desired by node k
W = randi(256, K, 1);

% keep track of number of transmissions
TOTAL_TRANSMISSIONS = 0;

%% TDMA all the way
if verbose
    disp('TDMA all the way');
end
% this method is technically incorrect, although the same
% probabilistically. I am changing the method so that rng state is
% meaningful
for k = 1:K
    TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
    while ~transmit_messages(length(W(k)), eps_vec(k))
        TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
    end
end
% final_messages = nan(size(W));
% while any(isnan(final_messages))
%     map = find(isnan(final_messages));
%     Kprime = length(map);
%     for k = 1:Kprime
%         R = transmit_messages(1, eps_vec(map));
%         TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1;
%         if verbose
%             disp(['Transmission ', num2str(TOTAL_TRANSMISSIONS)]);
%             disp([' k  #']);
%             disp([map(:) R]);
%         end
%         if R(k) == 1
%             final_messages(map(k)) = W(map(k));
%         end
%     end
% end
     
if verbose
    disp(['Total number of transmissions: ', num2str(TOTAL_TRANSMISSIONS)]);
end

end
