# nuclear_alignment.py

import cvxpy as cp
import numpy as np

# nuclear_alignment(I, m, epsilon, iter, quiet) runs the nuclear norm minimization
# and returns the precoding and decoding coefficient matrices V and U
# The inputs are
#	I: [K,K] matrix of interference indicators
#	m: number of transmissions (rows in V,U)
#	epsilon:	threshold for min. eigenvalue
#	iter:		number of iterations
#	quiet:	verbose output/debugging
# The outputs are
#	V: [m,K] final encoding matrix
#	U: [m,K] final decoding matrix
def nuclear_alignment(I, m, epsilon=.1, iter=5, quiet=False):

	K = np.size(I,0)
	U = cp.randn(m,K)

	print U
	for i in range(iter):

		V = nuc_al(I, U, 0, epsilon, quiet)
		U = nuc_al(I, V, 1, epsilon, quiet)
	
	return normalize(V), normalize(U)

def nuc_al(I, X, turn, epsilon=.1, quiet=False):

	m,K = np.shape(X)


	if not turn:
		V = cp.variable(m,K, name='V')
		U = X

	else:
		V = X
		U = cp.variable(m,K, name='U')

	f_cost = cp.parameter(name='f_cost')
	f_cost.value = 0

	J = cp.parameter(K,K, name='J')
	J.value = cp.zeros((K,K))


	# define the cost parameter
	for k in range(K):
		# create a list of interferer indeces Ik
		# from the interference set I
		Ik = np.arange(1,K+1)*I[k,:]	# careful about zero indexing...
		Ik = Ik[Ik>0] - 1
		#print 'I_%d = ' % k, Ik
		if len(Ik) > 0:
			for l in Ik:
				l = int(l)
				J[k,l] = U[:,k].T*V[:,l]	# interference terms
			f_cost = f_cost + cp.nuclear_norm(J[k,:])
			#f_cost = f_cost + cp.norm1(J[k,:])

	# create constraints
	constraints = []
	for k in range(K):
		c = cp.geq(U[:,k].T*V[:,k], epsilon)
		#c = cp.geq(cp.lambda_min(U[:,k].T*V[:,k]), epsilon)
		constraints.append(c)

	p = cp.program(cp.minimize(f_cost), constraints)
	print 'minimize: ', p.objective
	print 'subject to:'
	print p.constraints
	p.solve(quiet)

	if not turn:
		return V.value
	else:
		return U.value

# normalize column vectors of X
def normalize(X):
	norms = np.apply_along_axis(np.linalg.norm, 0, X)
	return X / norms.reshape(1,-1)
