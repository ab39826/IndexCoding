# solving for W2, where W0 and W1 are aligned and A_2 = {W3}
# automated as far as the building of the coefficient matrix for 0,1 alignment pair

from numpy.linalg import matrix_rank as mrank
import numpy as np

num_tx = 2; # number of transmissions
num_nodes = 4;

input = raw_input("Enter align nodes in form pair 1, pair 2 (Ex. 0,1): ");
input_list = input.split(',');
align_pairs = map(int, input_list);
num_aligns = len(align_pairs)/2;

A2 = [3]; # antidote set of W2

num_eqs = num_tx + np.size(A2);

# generate one equation per antidote
# each antidote equation is of the form
# [0,0,0,1.] where the 1. indicates that message 3 is known
eqs = np.zeros((num_eqs, num_nodes))
for ind,ant in enumerate(A2):
	eqs[ind,ant] = 1.0; # python differentiates between ints and floats

# generate one equation per transmission

# TODO: determine alignment constraint
alignment = [0,1]
# choose arbitrary scaling
sc = 2.0
# sc = np.random.randn(1)

# generate matrix of coefficients until rank constraint is met
mr = 0
A = np.random.randn(num_tx, num_nodes);

for x in range(num_aligns):
        A[0][align_pairs[x]] = 1
        A[1][align_pairs[x]] = sc
        A[0][align_pairs[x + 1]] = 1
        A[1][align_pairs[x + 1]] = sc
	
	
#while mr < num_tx:
#	A = np.matrix([ [1.0, 1.0], [sc, sc] ])
#	B = np.random.randn(num_tx, num_nodes - np.size(alignment))
#	C = np.bmat('A B')
#	mr = mrank(C)

for ind in range(num_tx):
	eqs[ind+np.size(A2),:] = A[ind]

# solve for W2
# currently manual approach for demonstration purposes
E1 = eqs[2] - sc*eqs[1]
E2 = E1 - E1[3]*eqs[0]
E3 = E2 / E2[2]

print E3 # [0,0,1,0]
