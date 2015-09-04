from alignment import *
I = np.mat('-1 1 0; 0 -1 0; 0 1 -1')
m, n = np.shape(I)
r = 2
iter = 100
eps = 1e-4
(V, U) = mixed_alignment(I, eps, iter, True)
J = np.eye(3)*-1
J[0,1:3] = 1
(V, U) = simple_alignment(2, J)
