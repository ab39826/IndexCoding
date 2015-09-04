%%
clc
clear all
close all

cvx_quiet(true) % make cvx silent

% I is the interference indicator sets, i.e. Ik = complement(union(Ak,Wk))
I = [0 0 0 1; ...
     0 0 1 0; ...
     1 1 0 0; ...
     0 0 1 0];
 
%  I = [[ 0.  0.  1.  1.]
%     [ 1.  0.  0.  1.]
%     [ 1.  1.  0.  1.]
%     [ 1.  1.  0.  0.]];

% I = zeros(5,5)


display(I)
K = size(I,1); % number of users
K = 10;
I = randn(K) > .3;
I(logical(eye(size(I)))) = 0;


m = 5; % number of transmissions
d = 1; % only one signal dimension
iter_nucnorm = 1; % #iterations of nuclear approximation
epsilon = .1;

display([num2str(K),'-user Network Coding with ', num2str(m), ' Transmissions.'])
display(' ');
display(['Running nuclear norm with ', num2str(iter_nucnorm), ' iterations'])

%% nuclear norm
U_init = randn(m,K);

tic
% [V U] = nuclear_NC_K_user(I, orthogonalize(U_rand), epsilon, iter_nucnorm);
[V U] = nuclear_NC_K_user(I, U_init, epsilon, iter_nucnorm);
display(['Nuclear norm algorithm: ', num2str(toc), ' sec'])

%%
V = full(V);
U = full(U);
Vn = V./norm(V);
Un = U./norm(U);
display(' ')
display(Un'*Vn)
X = Un'*Vn;

%%
% Vo = orthogonalize(V);
% Uo = orthogonalize(U);
% Vn = reshape(orthogonalize(V),m,K);
% Un = reshape(orthogonalize(U),m,K);

% check 

% [S_eig J_eig] = block_svd(U_l1, H, V_l1); % find useful and interference eigenvalues
% DoF_l1 = max(mean(sum(S_eig > DoF_accuracy, 1) - sum(J_eig > DoF_accuracy, 1)),0); % calculate DoF
% display(['DoF achieved: ', num2str(DoF_l1)])

