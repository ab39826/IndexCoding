function [ flag ] = batch_simulation(method, K, prefix, epsilons, MC, dest)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


dir = 'sims/';
postfix = '.txt';
for m = 1:MC
    disp(m);
    for i = 1:length(epsilons)
        error = false;
        eps = epsilons(i);
        disp(['  ', num2str(i), ': ', num2str(eps)])
        try
            if strcmp(method, 'ic3')
                t = index_coding_sim3(K, eps);
            elseif strcmp(method, 'ic4')
                t = index_coding_sim4(K, eps);
            elseif strcmp(method, 'ic')
                t = index_coding_sim2(K, eps);
            elseif strcmp(method, 'ics')
                t = index_coding_sim_simple(K, eps);
            elseif strcmp(method, 'tdma')
                t = tdma_sim(K, eps);
            elseif strcmp(method, 'rc2')
                t = random_coding_sim2(K, eps);
            elseif strcmp(method, 'bsic')
                t = bs_index_coding(K, eps, 0, dest);
            elseif strcmp(method, 'bsrc')
                t = bs_random_coding(K, eps, 0, dest);
            else
                disp('ERROR: no method found');
                error = true;
            end
                
        catch ME1
            disp(['ERROR: ', ME1.identifier, ' ', ME1.message]);
            error = true;
        end
        if t == -1
            error = true;
        end
        if ~error
            filename = [dir, prefix, '_', num2str(K), '_', num2str(eps), postfix];
            dlmwrite(filename, [t], '-append');
        end
    end
    
end

flag = true;

end

