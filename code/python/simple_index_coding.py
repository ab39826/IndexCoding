# solving for W2, where W0 and W1 are aligned and A_2 = {W3}


from numpy.linalg import matrix_rank as mrank
import numpy as np
from gen_antidotes import gen_antidotes
import sys

## Parameters
num_nodes = 4;
#print Antidotes

A0 = [1,2]
A1 = [0,3]
A2 = [3]	#  antidote set of W2
A3 = [0,1]
###
Antidotes = [A0,A1,A2,A3]
#Antidotes = gen_antidotes(num_nodes)

num_tx = 2; # number of transmissions

## Determine alignment constraints
# create interference sets (TODO: implement efficiently)
I = []
AI = []
for i in range(num_nodes):
	I.append(range(num_nodes))
	AI.append(range(num_nodes))


for node in range(num_nodes):
	I[node].remove(node)
	for a in Antidotes[node]:
		I[node].remove(a)
		AI[node].remove(a)

for i1 in I:
	for i2 in AI:
		if i1 == i2:
			print 'Contradiction in alignment constraints'
			sys.exit(1)

alignment = []
for i in I:
	if len(i) > 1:
		alignment.append(i)

## Generate transmission equations
# choose arbitrary scaling
sc = 2.0
# sc = np.random.randn(1)

# generate matrix of coefficients until rank constraint is met
mr = 0
while mr < num_tx:
	tx_eqns = np.random.randn(num_tx, num_nodes)
	for alignment_pair in alignment:
		tx_eqns[0, alignment_pair] = 1.0;
		tx_eqns[1, alignment_pair] = sc;
	mr = mrank(tx_eqns[:,list(set(range(num_nodes)).difference(alignment_pair))])

#print 'ant_eqns: ', ant_eqns
#print 'tx_eqns: ', tx_eqns


for Ai in range(num_nodes):

	# generate antidote equations. Each antidote equation is of the form
	# [0,0,0,1.] where the 1. indicates that message 3 is known
	ant_eqns = np.zeros((np.size(Antidotes[Ai]), num_nodes))
	for ind,ant in enumerate(Antidotes[Ai]):
		ant_eqns[ind,ant] = 1.0; # python differentiates between ints and floats

	# choose arbitrary scaling
	sc = 2.0
	# sc = np.random.randn(1)

	## Solve for message Wi
	# find the first variable to eliminate
	first = (Ai + 1) % num_nodes	# initialize to anything except variable of message i
	for i,eqn in enumerate(ant_eqns.T):
		if i != Ai and sum(eqn) == 0:
			first = i
			break

	#print 'first index to solve is ', first

	ratio =  tx_eqns[1,first]/tx_eqns[0,first]
	E1 = tx_eqns[1] - ratio*tx_eqns[0]
	#print 'E1: ', E1
	for i,eqn in enumerate(ant_eqns):
		ratio_i = tx_eqns[1,i] - ratio
		E1 = E1 - ratio_i*eqn
		#print 'E1: ', E1

	W = E1[Ai] / E1[Ai]
	print 'W%d ' % Ai, W
