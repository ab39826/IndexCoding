import numpy as np
from greedy_alignment import greedy_alignment, greedy_alignment_r



def nullvec(X, tol=1e-5):
	if np.shape(X)[0] == 0:
		V = np.eye(np.shape(X)[1])
	else:
		(U, s, Vt) = np.linalg.svd(X)
		V = Vt.T
	if np.shape(X)[1] > np.shape(X)[0]:
		z = V[:, -1]
	else:
		s = s < tol
		if np.any(s):
			z = V[:, s]
			z = z[:,-1]
		else:
			z = []
	return np.matrix(np.array(z).reshape(-1, 1))

def generate_U(V, J):
	(L, K) = np.shape(J)
	(m, K) = np.shape(V)

	U = np.zeros((m, L))
	for l in range(L):
		U[:,l] = np.array(nullvec(V[:, J[l,:] > 0].T)).reshape(-1)
	return U

def simple_alignment(m, J):
	(L, K) = np.shape(J)
	V = np.zeros((m,K))
	for k in range(L):
		Vk_null = V[:, J[k,:] > 0]
		if np.shape(Vk_null)[1] > 1:
			Vk_null = np.mat('1 ; %d' % (k+1))*np.ones((1, np.shape(Vk_null)[1]))
			V[:, J[k,:] > 0] = Vk_null
	
	Vk_rand = V[V==0]
	Vk_rand = np.random.randn(np.shape(Vk_rand)[0])
	V[V==0] = Vk_rand
	U = generate_U(V, J)
	return (np.matrix(V), np.matrix(U))

def check_alignment_conditions(m, J):
	alignment_truth = True
	(L,K) = np.shape(J)
	V_filled = np.zeros((m,K)) > 0
	for k in range(L):
		Vk_null = V_filled[:, J[k,:] > 0]
		if not np.any(np.any(Vk_null)):
			V_filled[:, J[k,:] > 0] = True
		else:
			alignment_truth = False
			break
	return alignment_truth

def mixed_alignment(I, eps, iter, verbose):
	r = 2
	interf_sum = np.inf
	valid_diag = False
	if verbose:
		print 'Mixed Alignment: trying to beat ', eps
		print 'iter (rank) 2 simple'

	(L, K) = np.shape(I)
	if check_alignment_conditions(r, I):
		(V, U) = simple_alignment(r, I)
	else:
		if L == 2:
			r = 1
		while r < min(np.shape(I)) and (interf_sum > eps or not valid_diag):
			r = r + 1
			type = 'greedy'
			(V, U) = greedy_alignment_r(I, r, iter)
			X = U.T*V
			interf_sum = np.sum(np.abs(X[I>0]))
			valid_diag = np.all(np.abs(X[I<0] > eps))
			if verbose:
				print 'iter (rank) %d %s:' % (r, type)
				print '\tinterf_sum is ', interf_sum
				print '\tvalid diag: ', valid_diag
	return (V, U)

def alignment(method, I, eps = 1e-4, iter = 100, verbose = False):
	if not np.any(np.any(I>0)):
		V = np.matrix(np.ones((1, np.shape(I)[0])))
		U = np.matrix(np.ones((1, np.shape(I)[0])))
	else:
		if method == 'greedy':
			(V, U) = greedy_alignment(I, eps, iter, verbose)
		elif method == 'mixed':
			(V, U) = mixed_alignment(I, eps, iter, verbose)
		else:
			print 'ERROR: ', method, ' is not a valud alignment method'
			V = np.nan
			U = np.nan
	return (V, U)

