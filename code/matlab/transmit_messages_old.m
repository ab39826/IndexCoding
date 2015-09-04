function [ R ] = transmit_messages(num_msgs, eps_vec)
%TRANSMIT_MESSAGES % sends messages in msg_vec with erasure probs. eps_vec
% msg_vec and eps_vec need not be same length
% Inputs
%  msg_vec: vector of messages
%  eps_vec: vector of erasure probs.
% Returns
%  R: one-zero matrix of received messages for each node
num_nodes = length(eps_vec);
% num_msgs = length(msg_vec);
R = zeros(num_nodes, num_msgs);
for k=1:num_nodes
    % send all messages to receiver with erasure eps(k)
    R(k,:) = binornd(1, 1-eps_vec(k), 1, num_msgs);
end

R = logical(R);

end