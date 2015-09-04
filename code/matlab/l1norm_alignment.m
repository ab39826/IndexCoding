function [V U] = l1norm_alignment(I, eps, epsilon, iter, verbose)
%nuclear_alignment Index coding interference alignment via l1 norm
% Inputs:
%   I: [L, K] interference matrix
%   epsilon: minimum value for diagonal terms
%   iter: number of iterations of algorithm
%   verbose: 1 for verbosity, 0 otherwise
% Outputs:
%   V: [r, K] encoding matrix
%   U: [r, L] decoding matrix

r = 1;
interf_sum = inf;
valid_diag = 0;

if verbose
    disp(['l1-Norm Alignment: trying to beat ', num2str(eps), ' (', num2str(iter), ' iterations)']);
end

while r < min(size(I)) && (interf_sum > eps || ~valid_diag)
    r = r + 1;
    [V U] = l1norm_alignment_r(I, r, epsilon, iter);
    X = U'*V; % system matrix
    interf_sum = sum(abs(X(I>0)));
    valid_diag = all(diag(X) > eps);
    if verbose
        disp(['iter (rank) ', num2str(r), ':']);
        disp(['  interf_sum is ', num2str(interf_sum)]);
        disp(['  valid diag: ', num2str(valid_diag)]);
    end
end

end