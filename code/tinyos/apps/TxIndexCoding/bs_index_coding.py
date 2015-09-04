import numpy as np
from Symbol import Symbol
from alignment import alignment, nullvec
from multirandperm import singlerandperm

def bs_index_coding(K, eps, verbose=True, dest=False):
	if dest == False:
		rand_dest = True
	else:
		rand_dest = False
	
	eps_vec = eps*np.ones(K)

	if verbose:
		print ' '
		print 'Number of receivers/nodes: ', K
		print 'Erasure prob is ', eps
		print '-----------'

	# generate random messages
	W = np.random.randint(1,257, (K,1))

	# store final received messages. goal is to "de-NaN" by the end
	final_messages = np.nan*np.zeros((K, 1))
	# keep track of all transmitted and received messages/symbols
	tx_symbols = np.array([]) # [1 -by- # of transmissions]

	# keep track of number of transmissions
	TOTAL_TRANSMISSIONS = 0

	## Base Station - to - cellular model
	# Uplink is assumed perfect, i.e. the BS has access to all messages and
	# their destinations
	if rand_dest:
		if verbose:
			print 'Message destinations chosen randomly'
		dest = singlerandperm(K); # receiver i wants message dest(i)
		print dest
	A = np.diag(W.reshape(-1)) # receiver (row) i has access to the message it plans to send
	mat_dest = (np.arange(K), np.array(dest))
	signal_space = np.zeros((K,K))>0
	signal_space[mat_dest] = True;
	I = compute_interferers(A, signal_space)
	J = I.astype(float)
	J[mat_dest] = -1
	map = np.arange(K)
	
	if verbose:
		print 'Interferer matrix is:'
		print J
	
	i = 1
	while np.any(np.isnan(final_messages)):
		Kprime = len(map);
		if verbose:
			print 'Remaining ', Kprime, ' nodes are: '
			print map

		## special case for one remaining node
		if Kprime == 1:
			TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1
			while not transmit_messages(1, eps_vec[map]):
				TOTAL_TRANSMISSIONS = TOTAL_TRANSMISSIONS + 1
			final_messages[map] = W[map]
		else:
			## Generate next m transmissions
			(V, U) = alignment('mixed', J, 1e-4, 100, False)
			m = np.shape(V)[0]
			if verbose:
				print 'Minimum rank is ', m

			# generate next symbol based on current V
			L = len(tx_symbols);
			if i == 1:
				L = 0

			unsolved = np.ones(Kprime) > 0
			m_i = 0
			while np.all(unsolved) and m_i < m:
				tx_symbols = np.append(tx_symbols, Symbol(V[m_i,:], W, map))
				R = transmit_messages(1, eps_vec[map])
				if i == 1:
					rx_symbols = R
				else:
					rx_symbols = np.bmat([rx_symbols, R])
				if verbose:
					print 'Transmission ', m_i+1, '/', m
					print rx_symbols.astype(int)
				TOTAL_TRANSMISSIONS += 1
				# solve for messages if possible
				(unsolved, final_messages) = bs_decode_messages(dest, Kprime, map,
						rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose)
				m_i += 1
				i += 1
			# update data structures
			map = np.nonzero(np.isnan(final_messages.reshape(-1)))[0]
			rx_symbols = rx_symbols[unsolved, :]
			J = J[unsolved, :]
			I = I[unsolved, :]
			A = A[unsolved, :]
	if verbose:
		print 'Total number of transmissions: ', TOTAL_TRANSMISSIONS
	return TOTAL_TRANSMISSIONS


def transmit_messages(num_msgs, eps_vec):
	num_nodes = len(eps_vec)
	R = np.matrix(np.random.rand(num_nodes, num_msgs) > np.matrix(eps_vec).T*np.ones((1,num_msgs)))
	return R

def compute_interferers(A, signal_space):
	I = np.ones(np.shape(A))
	I[A!=0] = 0
	I[signal_space] = 0
	I = I>0
	return I

def bs_decode_messages(dest, Kprime, map, rx_symbols, tx_symbols, A, I, J, W, final_messages, verbose):
	unsolved = np.zeros(Kprime) > 0
	if verbose:
		print 'k\tTruth\tDecoded'
	for k in range(Kprime):
		Wk = decode_message(I[k,:], tx_symbols[np.array(rx_symbols[k,:]).reshape(-1)], A[k,:], np.nonzero(J[k,:] == -1)[0][0])

		if Wk == W[dest[map[k]]]:
			final_messages[map[k]] = Wk
		else:
			unsolved[k] = True

		if verbose:
			print '%d\t%d\t\t%s' % (map[k], W[dest[map[k]]], Wk)

	return (unsolved, final_messages)

def decode_message(Ik, Sk, Ak, k):
	m = len(Sk)
	if m > 0:
		K = np.shape(Ik)[0]
		V = np.matrix(np.array([s.v_coeffs for s in Sk]).reshape(-1).reshape(m, K))
		Svals = np.matrix([float(s.val) for s in Sk]).T

		Vk_null = V[:, Ik]
		if np.shape(Vk_null)[0] == 0:
			u = np.ones((np.shape(V)[0], 1))
		else:
			u = nullvec(Vk_null.T)

		if np.shape(u)[0] > 0:
			#print u
			#print V
			#print np.shape(u)
			#print np.shape(V)
			x = list(np.array(u.T*V).reshape(-1))
			val_at_k = np.abs(x[k]) > 1e-15
			if val_at_k:
				Ak = np.array(Ak).reshape(1, -1)
				Wk = int(np.round((u.T*Svals - u.T*V*Ak.T)/x[k]))
			else:
				print 'x[k] = ', x[k]
				print 'val = ', np.round((u.T*Svals - u.T*V*Ak.T)/x[k])
				Wk = 'ERROR: no good nullvec'
		else:
			Wk = 'ERROR: no nullvec'
	else:
		Wk = 'ERROR: no received symbols'
	return Wk

