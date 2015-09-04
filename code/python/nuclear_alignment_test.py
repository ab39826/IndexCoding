# nuclear_alignment.py

import numpy as np
from nuclear_alignment import nuclear_alignment


# nuclear_IA_K_user(I, U, epsilon, iter) runs the nuclear norm minimization
# and returns the precoding and decoding coefficient matrices V and U
# The inputs are
#	I: [K,K] matrix of interference indicators
#	U: [m,K] initialization decoding matrix
#	epsilon:	threshold for min. eigenvalue
#	iter:		number of iterations

#def nuclear_IA_K_user(I, U, epsilon=.1, iter=5):
	# obtain problem parameters
#I = np.array([ [0,1,1], [1,0,0], [1,0,0] ])
#I = np.array([ [0,1,0,1], [0,0,1,0], [1,1,0,0], [0,0,1,0] ])
I = np.zeros((5,5))

epsilon = .1
iter = 1
K = np.size(I,0)
m = 1

V,U = nuclear_alignment(I, m, epsilon, iter, quiet=False)

print
print U.T*V
print
print I

W = np.random.randint(1,255,[K,1])
A = np.matrix(np.zeros((K,K)))

for k in range(K):
	for l in range(K):
		if k != l and I[k,l] != 1:
			A[k,l] = W[l]


print
for k in range(K):
	W_dec = ((U.T*V)[k,:]*W - (U.T*V)[k,:]*A[k,:].T)/(U.T*V)[k,k]
	print 'Message %d truth: %d decoded %.2f' % (k, W[k], W_dec)
