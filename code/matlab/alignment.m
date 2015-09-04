function [V U] = alignment(method, I, m, eps, iter, verbose)
%alignment Index coding interference alignment
% method: 'greedy', 'nuclear', 'l1norm' describing the method to use
% I: interference matrix
% eps: see method
% iter: number of iterations
% verbose: show extra output


% send a single linear combination if no interference

if ~any(any(I>0))
    V = ones(1,size(I,1));
    U = V;
else
    if nargin < 4
        eps = 1e-4;
    end
    if nargin < 5
        iter_nuc = 3;
        iter_gr = 100;
    else
        iter_nuc = iter;
        iter_gr = iter;
    end
    if nargin < 6
        verbose = 0;
    end

    epsilon = .1;

    if strcmp(method, 'greedy')
        [V U] = greedy_alignment(I, eps, iter_gr, verbose);
    elseif strcmp(method, 'nuclear')
        [V U] = nuclear_alignment(I, m, epsilon, iter_nuc, verbose);
    elseif strcmp(method, 'l1norm')
        [V U] = l1norm_alignment(I, eps, epsilon, iter_nuc, verbose);
    elseif strcmp(method, 'mixed')
%         iter_nuc = 3;
        [V U] = mixed_alignment(I, eps, iter_gr, verbose); 
    else
        disp(['ERROR - ', method, ' is not a valid alignment method.']);
        V = nan; U = nan;
    end
end

end

