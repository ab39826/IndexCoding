function [antidotes map] = update_antidotes(first, old_antidotes, R, map, msg_vec, decoded)
%update_antidotes Update final messages matrix
%   Update the antidotes matrix to reflect the newly received symbols
%   indicated by R
% Inputs:
%  previous_antidotes: previous antidote matrix
%  R: one-zero matrix indicating if node (row) j received symbol (col) k
%  map: maps the rows/cols of R to a node

if first == true
    K = size(R,1);
    done_vec = diag(R) == 1;
    map(done_vec) = [];
    L = length(map);
    antidotes = zeros(L, L);
    for k=1:L
        for l = 1:L
            antidotes(k,l) = msg_vec(map(l)).*R(map(k),map(l));
        end
    end
else
    l = length(msg_vec);
    [r1 r2] = size(R);
    antidotes = ones(r1,1)*msg_vec(l-r2+1:l)'.*R;
    inds = logical(decoded);
    antidotes(inds,:)  = [];
    map(inds) = [];
    old_antidotes(inds,:) = [];
    old_antidotes(:,inds) = [];
    antidotes = [old_antidotes antidotes];
end
end
