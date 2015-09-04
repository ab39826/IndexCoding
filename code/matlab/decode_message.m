function [Wk] = decode_message(Ik, Sk, Ak, k)
%decode_message Decode for message W using the general decoding scheme
% Ik: interferer of row (receiver) k
% Sk: transmissions received by row k
% Ak: antidotes of row (receiver) k

m = length(Sk);
if m > 0    
    K = size(Ik,2);
    % build V matrix and Svals from received symbols
%     V = zeros(m,K);
%     Svals = zeros(m,1);
%     for i = 1:m
%         V(i,:) = Sk(i).v_coeffs;
%         Svals(i) = Sk(i).val;
%     end
    V = reshape([Sk.v_coeffs], K, m)';
    Svals = [Sk.val]';
    
    Vk_null = V(:, Ik); % interference columns of V
    if size(Vk_null,1) == 0
        u = ones(size(V,1),1);
    else
        u = nullvec(Vk_null');
    end
    % choose the best u if more than one exists
    if size(u,1) > 0
        x_multi = u'*V;
        val_at_k = abs(x_multi(:,k)) > 1e-15;
        y = find(val_at_k == 1);
        if size(y == 1) > 0
            u = u(:,y(1));
            x = u'*V;
            if abs(x(k)) > 1e-15
                Wk = round((u'*Svals - u'*V*Ak')/x(k));
            else
                disp(['x(k) = ', num2str(x(k))]);
                disp(['val = ', num2str(round((u'*Svals - u'*V*Ak')/x(k)))]);
                Wk = 'ERROR: divide by zero';
            end
        else
            Wk = 'ERROR: no good nullvec';
        end
    else
        Wk = 'ERROR: no nullvec';
    end
else
    Wk = 'ERROR: no rx symbols';
end

end
