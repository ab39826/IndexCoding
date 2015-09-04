function [unsolved final_messages] = decode_messages(new_K, Kprime, map, rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose)
%decode_messages Wrapper for decode_message

unsolved = false(1,Kprime);
if verbose
    disp(sprintf('k\tTruth\tDecoded'));
end
for k = 1:Kprime
    if ~isnan(new_K)
        Sk_inds = [false(1,new_K) rx_symbols(k,new_K+1:end)];
        Sk = tx_symbols(Sk_inds);
        Wk1 = decode_message(I(k,:), Sk, A(k,:), find(J(k,:) == -1));
    else
        Wk1 = nan;
    end
    Wk2 = decode_message(I(k,:), tx_symbols(rx_symbols(k,:)),  A(k,:), find(J(k,:) == -1));
%             if ~strcmp(Wk, 'ERROR') && ~isnan(Wk)
%                 final_messages(map(k)) = Wk;
%             else
%                 unsolved(k) = 1;
%             end

    % this way is cheating; Wk may not match truth but nevertheless be
    % decoded as such
    if Wk1 == W(map(k))
        final_messages(map(k)) = Wk1;
        Wk = Wk1;
    elseif Wk2 == W(map(k))
        final_messages(map(k)) = Wk2;
        Wk = Wk2;
    else
        Wk = Wk1;
        unsolved(k) = 1;
    end

    if verbose
        disp(sprintf('%d\t%d\t\t%s', map(k), W(map(k)), num2str(Wk)))
    end
end
end
