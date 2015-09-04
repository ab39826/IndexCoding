function [ I ] = compute_interferers( A, signal_space )
%compute_interferers Compute interferer matrix

I = ones(size(A));
I(A~=0) = 0;
I(signal_space) = 0;
I = logical(I);

end

