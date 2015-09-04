

#from numpy.linalg import matrix_rank as mrank
from nuclear_alignment import nuclear_alignment
import transmission
import Message
import numpy as np
import sys

## Parameters
num_nodes = 16
min_eps = .1
num_msgs = 2
#

eps_vec = np.random.uniform(low=min_eps,size=num_nodes)

print 'Number of receivers(nodes): ', num_nodes
print
print 'Erasures are: ', eps_vec

# generate random messages. Each row i is desired by receiver i
message_matrix = np.random.random_integers(1, 255, [num_nodes, num_msgs])
Messages = Message.generate_messages(message_matrix)

# store final received messages. goal is to "de-NaN" by the end
final_messages = np.empty((num_nodes, num_msgs))

## Round Robin to start
msg_vec = Messages[:,0]	# first round of messages
sym_vec = np.empty(num_nodes, dtype=object)
for i in range(num_nodes):
	sym_vec[i] = Message.Symbol([1], [msg_vec[i]])
        
print
print 'Round Robin symbols are: ', sym_vec

R = transmission.transmit_symbols(sym_vec, eps_vec)
#print
#print 'Recieved symbols are: ', R

# if a desired message is received, move it to final_messages
for i in range(num_nodes):
	for sym in R[i]:
		if sym.msg_inds[0][0] == i: # if message is intended for receiver i
			final_messages[i,sym.msg_inds[0][1]] = sym.val

Antidotes = transmission.update_antidotes(R)
print
print 'Antidotes are: ', Antidotes   #-1 denotes node is out of Antidote set

Interferers, interf_map = transmission.compute_interferers(Antidotes)
print
print 'Remaining receivers are: ', interf_map
print 'Interference indicator sets are'
print Interferers


#### for quick test, should be replaced with symbol/message data structures
K = len(interf_map)
W = np.matrix(np.zeros((K,1)))
A = np.matrix(np.zeros((K, K)))
I = (Interferers - 1)*-1
I[np.diag_indices_from(I)] = 0
for index,node in enumerate(interf_map):
	W[index,0] = sym_vec[node].val
	for jindex,i in enumerate(I[index,:]):
		if i == 1:
			A[index,jindex] = sym_vec[interf_map[jindex]].val


## nuclear norm approx
num_transmissions = 2*K # int(K/2) + 1
print
print 'num transmissions is ', num_transmissions
V, U = nuclear_alignment(Interferers, num_transmissions, .1, 1)
print
print 'U.T*V is:'
print U.T*V

print
for k in range(K):
	W_dec = ((U.T*V)[k,:]*W - (U.T*V)[k,:]*A[k,:].T)/(U.T*V)[k,k]
	print 'Message %d truth: %d decoded: %.2f' % (k, W[k], W_dec)
