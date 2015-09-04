function [V U] = mixed_alignment(I, eps, iter, verbose)
%mixed_alignment Index coding interference alignment via mix of ADMiRA and
%l1norm
% Inputs:
%   I: [L, K] interference matrix
%   eps: allowed upper bound for sum of interference terms
%        and lower bound for product of desired terms
%   epsilon: minimum value for diagonal terms
%   iter_nuc: number of iterations of convex optimization algorithm
%   iter_gr: number of iterations of ADMiRA algorithm
%   verbose: 1 for verbosity, 0 otherwise
% Outputs:
%   V: [r, K] encoding matrix
%   U: [r, L] decoding matrix


r = 2;
interf_sum = inf;
valid_diag = 0;

if verbose
    disp(['Mixed Alignment: trying to beat ', num2str(eps)]);
    disp('iter (rank) 2 simple')
end

[L K] = size(I);
if check_alignment_conditions(r, I)
    [V U] = simple_alignment(r, I);
else
    if L == 2
        r = 1;
    end
    while r < min(size(I)) && (interf_sum > eps || ~valid_diag)
        r = r + 1;
%         if all(sum(I>0,2) < 2)
%             type = 'l1norm';
%             [V U] = l1norm_alignment_r(I, r, epsilon, iter_nuc);
%         else
            type = 'greedy';
            [V U] = greedy_alignment_r(I, r, iter);
%         end
        X = U'*V; % system matrix
        interf_sum = sum(abs(X(I>0)));
        valid_diag = all(abs(X(I<0)) > eps);
        if verbose
            disp(['iter (rank) ', num2str(r), ' ', type, ':']);
            disp(['  interf_sum is ', num2str(interf_sum)]);
            disp(['  valid diag: ', num2str(valid_diag)]);
        end
    end
end

end

