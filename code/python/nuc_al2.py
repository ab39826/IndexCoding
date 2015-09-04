import cvxpy as cp
import numpy as np

I = np.random.randn(10,10) > .4
I[np.diag_indices_from(I)] = 0
K = np.shape(I)[0]

X = cp.variable(K,K, name='X')
const = []
for i in range(K):
	for j in range(K):
		if I[i,j] > 0:
			c = cp.equals(X[i,j],0)
			const.append(c)
c = cp.equals(cp.diag(X),1)
const.append(c)

p = cp.program(cp.minimize(cp.nuclear_norm(X)), const)
p.solve(quiet=False)
print X.value
