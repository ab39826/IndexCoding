import numpy as np
from numpy.linalg import svd


def APsiUV(alpha, A, PsiU, PsiV):
	diagalpha = np.matrix(np.diag(np.array(alpha).reshape(-1)))
	z = PsiU*diagalpha*PsiV.T
	b = A(z)
	return b

def APsitUV(b, At, PsiU, PsiV):
	t = At(b)
	alpha = PsiU.T*t*PsiV
	return np.matrix(np.diag(alpha)).T

def admira(r, b, m, n, iter, A, A_star):
	if 2*r > min(m,n):
		r_prime = min(m,n)
	else:
		r_prime = 2*r

	# initialization
	X_hat = np.random.randn(m,n) # step 1
	Psi_hatU = np.matrix([])
	Psi_hatV = np.matrix([])
	for i in range(iter):
		Y = A_star(b - A(X_hat))
		(U, s, Vt) = svd(Y)
		Psi_primeU = U[:, 0:r_prime]
		Psi_primeV = Vt.T[:, 0:r_prime]
		if i > 0:
			Psi_tildeU = np.bmat([Psi_primeU, Psi_hatU])
			Psi_tildeV = np.bmat([Psi_primeV, Psi_hatV])
		else:
			Psi_tildeU = Psi_primeU
			Psi_tildeV = Psi_primeV
		AP = lambda b: APsiUV(b, A, Psi_tildeU, Psi_tildeV)
		APt = lambda s: APsitUV(s, A_star, Psi_tildeU, Psi_tildeV)
		ALS = lambda b: APt(AP(b))
		(s, res, iter) = cgsolve(ALS, APt(b), 1e-6, 100, False)
		X_tilde = Psi_tildeU*np.matrix(np.diag(np.array(s).reshape(-1)))*Psi_tildeV.T
		(U, s, Vt) = svd(X_tilde)
		Psi_hatU = U[:, 0:r]
		Psi_hatV = Vt.T[:, 0:r]
		X_hat = Psi_hatU*np.diag(s[0:r])*Psi_hatV.T

	return X_hat

def greedy_alignment_r(I, r, iter):
	(m, n) = np.shape(I)
	#interfidx = np.nonzero(np.ravel(I) > 0)
	#diagidx = np.nonzero(np.ravel(I) < 0)
	interfidx = np.nonzero(I > 0)
	diagidx = np.nonzero(I < 0)
	#idx = np.unique(np.hstack([interfidx[0], diagidx[0]]))
	X = np.matrix(np.zeros((m,n)))
	X[diagidx] = 1
	X[interfidx] = 0
	idx = np.nonzero(I != 0)
	A = lambda X: X[idx]
	def A_star(b):
		X = np.matrix(np.zeros((m,n)))
		X[idx] = np.array(b).reshape(-1)
		return X
	b = A(X)
	X_hat = admira(r, b, m, n, iter, A, A_star)
	(Ufull, sfull, Vtfull) = svd(X_hat)
	s = sfull[0:r]
	U = (Ufull[:,0:r]*np.diag(s)).T
	V = Vtfull[0:r, :]
	return (V, U)
	
def cgsolve(A, b, tol, maxiter, verbose=True):
	x = np.matrix(np.zeros( (len(b),1) ))
	r = b
	d = r
	delta = float(r.T*r)
	delta0 = float(b.T*b)
	numiter = 0
	bestx = x
	try:
		bestres = np.sqrt(delta/delta0)
	except ZeroDivisionError:
		bestres = np.nan
	while numiter < maxiter and delta > delta0 * tol**2:
		q = A(d)
		alpha = float(delta/(d.T*q))
		x = x + alpha*d

		if (numiter+1) % 50 == 0:
			r = b - A(x)
		else:
			r = r - alpha*q

		deltaold = delta
		delta = float(r.T*r)
		beta = delta/deltaold
		d = r + beta*d
		numiter += 1
		sqrtd = np.sqrt(delta/delta0)
		if sqrtd < bestres:
			bestx = x
			bestres = sqrtd

		if verbose and (numiter % verbose) == 0:
			print 'cg: Iter = %d, Best residual = %8.3e, Current residual = %8.3e' % (numiter, bestres, sqrtd)
	
	if verbose:
		print 'cg: Iterations = %d, best residual = %14.8e' % (numiter, bestres)
	
	return (bestx, bestres, numiter)

def greedy_alignment(I, eps, iter, verbose):
	r = 1
	interf_sum = np.Inf
	valid_diag = False

	if verbose:
		print 'Greedy Alignment: trying to beat ', eps
	
	while r < min(np.shape(I)) and (interf_sum > eps or not valid_diag):
		r = r + 1
		(V, U) = greedy_alignment_r(I, r, iter)
		X = U.T*V
		interf_sum = np.sum(np.abs(X[I>0]))
		valid_diag = np.all(np.abs(X[I<0] > eps))
		if verbose:
			print 'iter (rank) %d:', r
			print '\tinterf_sum is ', interf_sum
			print '\tvalid diag: ', valid_diag
	return (V, U)
