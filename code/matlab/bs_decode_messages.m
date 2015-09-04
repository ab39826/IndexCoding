function [unsolved final_messages] = bs_decode_messages(dest, Kprime, map, rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose)
%bs_decode_messages Wrapper for decode_message for the BS model

unsolved = false(1,Kprime);
if verbose
    disp(sprintf('k\tTruth\tDecoded'));
end
for k = 1:Kprime
    Wk = decode_message(I(k,:), tx_symbols(rx_symbols(k,:)),  A(k,:), find(J(k,:) == -1));

    if Wk == W(dest(map(k)))
        final_messages(map(k)) = Wk;
    else
        unsolved(k) = 1;
    end

    if verbose
        disp(sprintf('%d\t%d\t\t%s', map(k), W(dest(map(k))), num2str(Wk)))
    end
end
end
