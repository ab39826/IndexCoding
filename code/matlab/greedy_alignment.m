function [V U] = greedy_alignment(I, eps, iter, verbose)
%greedy_alignment Index coding interference alignment via ADMiRA
% Inputs:
%   I: [L, K] interference matrix
%   eps: allowed upper bound for sum of interference terms
%        and lower bound for product of desired terms
%   iter: number of iterations of ADMiRA algorithm
%   verbose: 1 for verbosity, 0 otherwise
% Outputs:
%   V: [r, K] encoding matrix
%   U: [r, L] decoding matrix


r = 1;
interf_sum = inf;
valid_diag = 0;

if verbose
    disp(['Greedy Alignment: trying to beat ', num2str(eps)]);
end

while r < min(size(I)) && (interf_sum > eps || ~valid_diag)
    r = r + 1;
    [V U] = greedy_alignment_r(I, r, iter);
    X = U'*V; % system matrix
    interf_sum = sum(abs(X(I>0)));
    valid_diag = all(abs(X(I<0)) > eps);
    if verbose
        disp(['iter (rank) ', num2str(r), ':']);
        disp(['  interf_sum is ', num2str(interf_sum)]);
        disp(['  valid diag: ', num2str(valid_diag)]);
    end
end

end

