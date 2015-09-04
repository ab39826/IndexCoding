function [ alignment_truth ] = check_alignment_conditions(m, J )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


alignment_truth = true;
[L K] = size(J);
V_filled = false(m, K);
for k = 1:L
    Vk_null = V_filled(:, J(k,:) > 0);
    if ~any(any(Vk_null))
        V_filled(:, J(k,:) > 0) = true;
    else
        alignment_truth = false;
        break;
    end
end

end

