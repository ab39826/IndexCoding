## transmit_msgs.py

import numpy as np
from numpy.random import rand, binomial

def transmit_msgs(msg_vec, eps_vec):
	# sends messages in msg_vec with erasure probs. eps_vec
	# msg_vec and eps_vec need not be same length
	num_nodes = len(eps_vec)
	num_msgs = len(msg_vec)
	rx_msg_vec = []
	for eps in eps_vec:
		# send all messages to receiver with erausre eps
		A = binomial(1, eps, num_msgs) * range(1,num_nodes+1)
		A = A[A>0] - 1	# indeces of received messages
		rx_msg_vec.append(list(np.array(msg_vec)[A]))
	return rx_msg_vec

def transmit_symbols(symbol_vec, eps_vec):
	# sends symbols in symbol_vec with erasure probs. eps_vec
	# symbol_vec and eps_vec need not be same length
	num_nodes = len(eps_vec)
	num_symbols = len(symbol_vec)
	rx_symbol_vec = []
	for eps in eps_vec:
		# send all symbols to receiver with erausre eps
		A = binomial(1, eps, num_symbols) * range(1,num_nodes+1)
		A = A[A>0] - 1	# indeces of received messages
		rx_symbol_vec.append(list(np.array(symbol_vec)[A]))
	return rx_symbol_vec


# Takes a 2-D array of received symbols
# Returns a 2-D array of antidotes
def update_antidotes(R):
	num_nodes = len(R)
	Antidotes = []
	ant_vec = []
	for i in range(num_nodes):
		for msg in R[i]:
			msg = [msg]
			ant_vec.append(msg[0].msg_inds[0][0])
		Antidotes.append(ant_vec)
		ant_vec = []
	for node in range(num_nodes):
		if Antidotes[node].count(node) != 0:
			Antidotes[node] = -1
	return Antidotes

# Uses the antidote sets to determine the
# interferer indicator sets, defined as
# Ik = W - union(Ak, Wk)
# if the antidote set is -1, the receiver
# has received its message and will be skipped.
# Also returns the map indicating which row
# corresponds to which receiver (since some 
# receivers will be skipped)
def compute_interferers(Antidotes):
	# first determine interf_map
	interf_map = []
	ignore_map = []

	num_nodes = len(Antidotes)
	Interferers = np.ones((num_nodes,num_nodes)) # all are interferers until proven innocent
	for k,Ak in enumerate(Antidotes):
		if Ak != -1:
			Interferers[k, Ak] = 0
			interf_map.append(k)
		else:
			ignore_map.append(k)

	# remove rows/cols that we do not care about
	Interferers = np.delete(Interferers, ignore_map, axis=0)
	Interferers = np.delete(Interferers, ignore_map, axis=1)
	# diag corresponds to own message; will never be an interferer
	Interferers[np.diag_indices_from(Interferers)] = 0
	return Interferers, interf_map
