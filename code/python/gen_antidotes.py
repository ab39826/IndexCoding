# gen_antidotes.py

import numpy as np
from numpy.random import rand, binomial
import pprint # for nice printing

#TODO: add flag w.r.t. getting yourself as an antidote
def gen_antidotes(num_nodes, eps_vec=None):

	if eps_vec is None:
		eps_vec = rand(num_nodes)
	
	Antidotes = []
	for eps in eps_vec:
		A = binomial(1, eps, num_nodes)*range(1,num_nodes+1)
		#print A
		A = A[A>0] - 1
		Antidotes.append(list(A))

	return Antidotes

## Parameters
#num_nodes = 10
#eps_vec = rand(num_nodes)	# erasure probabilities
##eps_vec = .3*np.ones(num_nodes)
##print eps_vec
#msgs_per_node = 1

#for round in range(msgs_per_node):
	#Antidotes = gen_antidotes(num_nodes)
	#pprint.pprint(Antidotes)
