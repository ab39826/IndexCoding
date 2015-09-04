from cvxopt import matrix, spmatrix, normal, setseed, blas, lapack, solvers
import nucnrm
import numpy as np

# Solves a randomly generated nuclear norm minimization problem 
#
#    minimize || A(x) + B ||_*
#
# with n variables, and matrices A(x), B of size p x q.

setseed(0)



m, K = 2, 4
p, q, n = 3, 1, 8

U = np.random.randn(m,K)
A = np.zeros((p*q,n))
A[0,1] = U[0,0]
A[0,2] = U[1,0]
A[1,3] = U[0,0]
A[1,4] = U[1,0]
A[2,5] = U[0,0]
A[2,6] = U[1,0]
	
A = matrix(A)
B = matrix(np.zeros((p,q)))

G = np.zeros((1,n))
G[0,0] = U[0,0]
G[0,1] = U[1,0]
G = matrix(G)
h = matrix([.1])


# options['feastol'] = 1e-6
# options['refinement'] = 3

sol = nucnrm.nrmapp(A, B, G=G, h=h)

x = sol['x']
Z = sol['Z']
