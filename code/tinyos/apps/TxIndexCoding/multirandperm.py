import numpy as np

def multirandperm(K, n):
	inds = np.zeros((n,K))
	for i in range(n):
		inds[i,:] = singlerandperm(K)
	return inds

def singlerandperm(K):
	perm = np.random.permutation(K)
	rangeinds = np.arange(K)
	reorder = rangeinds[perm == rangeinds]
	for i in range(0, len(reorder), 2):
		if i == len(reorder) - 1:
			ind = i % (K-1)
			perm[reorder[i]] = perm[ind]
			perm[ind] = reorder[i]
		else:
			# switch the two elements
			perm[reorder[i]] = reorder[i+1]
			perm[reorder[i+1]] = reorder[i]
	return perm

def pairingperm(K):
	perm = []
	for i in range(0, K-1, 2):
		perm.extend(range(i, i+2)[::-1]);
	if K % 2 == 1:
		perm[0] = K-1
		perm.append(1)
	return np.array(perm)


