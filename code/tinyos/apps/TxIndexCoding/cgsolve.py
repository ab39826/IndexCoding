
import numpy as np

def cgsolve(A, b, tol, maxiter, verbose=True):
	x = np.matrix(zeros( (len(b),1) ))
	r = b
	d = r
	delta = float(r.T*r)
	delta0 = float(b.T*b)
	numiter = 0
	bestx = x
	bestres = np.sqrt(delta/delta0)
	while numiter < maxiter and delta > delta0 * tol**2:
		q = A(d)
		alpha = delta/(d.T*q)
		x = x + alpha*d

		if (numiter+1) % 50 == 0:
			r = b - A(x)
		else:
			r = r - alpha*q

		deltaold = delta
		delta = r.T*r
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
