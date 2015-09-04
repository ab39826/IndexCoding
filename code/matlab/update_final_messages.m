function [ final_messages antidotes map ] = update_final_messages(final_messages, old_antidotes, map, R, msg_vec)
%update_final_messages Update final messages matrix
%   Update the final_messages matrix to reflect the newly received symbols
%   indicated by R
% Inputs:
%  final_messages: previous matrix of decoded messages
%  R: one-zero matrix indicating if node (row) j received symbol (col) k
%  map: maps the rows/cols of R to a node

K = size(R,1);
W = diag(R);
done_vec = [];
for k = 1:K
    if W(k) == 1
        final_messages(k) = msg_vec(k);
        done_vec(end+1) = k;
    end
end
map(done_vec) = [];
L = length(map);
antidotes = zeros(L, L);
for k=1:L
    for l = 1:L
        antidotes(k,l) = msg_vec(map(l)).*R(map(k),map(l));
end
end

