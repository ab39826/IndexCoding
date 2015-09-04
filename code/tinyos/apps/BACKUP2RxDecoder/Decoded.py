#!/usr/bin/python

import time
import numpy as np
import sys

#tos stuff
from DecodedMsg import *
from tinyos.message import MoteIF

class MyClass:
	def __init__(self,N):
		self.prevtime = time.time()
		self.N = N
		self.A = make_A_matrix(self.N)
		self.current_row = 0;
		#self.sym = [3]; #works
		#self.sym = [3.5]; #so does this, changed header
		#self.sym = self.A*np.matrix(np.ones((N,1)))
		#self.data = np.mat('[10.7; 1; 0; 1; .1; 6; .2; 1]')
		#self.data = np.random.randint(255,size=(N,1)) #random integer, type ndarray
		rndseed = np.random.RandomState(2413)
		#self.data = np.mat(np.random.randint(255,size=(N,1))) #type core.defmatrix.matrix
		self.data = np.mat(rndseed.randint(255,size=(N,1))) #type core.defmatrix.matrix
		#self.data[2,:] = 0.;
		#self.data[4,:] = 1.;
		#self.data[6,:] = 2.;
		print 'data is'
		print self.data
		self.sym = self.A*self.data
		#self.rndV = np.mat([-40, -40, -40, -40, -40, -40, -40, -40])
		# Create a MoteIF
		print 'symbols are'
		print self.sym
		self.mif = MoteIF.MoteIF()
		# Attach a source to it
		self.source = self.mif.addSource("sf@localhost:9002")
		
		# SomeMessageClass.py would be generated by MIG
		self.mif.addListener(self, DecodedMsg)

	def initialSend(self):
		#print 'initial send'
		smsg1 = DecodedMsg()
		smsg1.set_crow(255)
		smsg1.set_V_coeff(self.data[(2,4,6),:])
		#only send the nonzero side information (j<A in tinyos code)?
		self.mif.sendMsg(self.source, 0xFFFF, smsg1.get_amType(), 0, smsg1)
		#print 'end initial send'

	def send(self):
		smsg = DecodedMsg()
		#print 'type of A is ', type(self.A)
		print 'cr ', self.A[self.current_row]
		#print 'type of cr ', type(self.A[self.current_row])
		
		#random coefficients instead
		#rndRow = np.random.randn(1,self.N)
		#print 'random row is', rndRow[0,:]
		#print self.rndV
		#self.rndV = np.bmat([[self.rndV], [rndRow]])
		#print 'matrix of random rows is'
		#print self.rndV
		#smsg.set_V_coeff(rndRow[0,:])
		#also change data symbols
		#self.rndSym = np.dot(rndRow[0,:],self.data)
		#smsg.set_data(self.rndSym)

		smsg.set_V_coeff(self.A[self.current_row])
		smsg.set_data(self.sym[self.current_row]) #use current row each time?
		#print type(self.A[0,0])
		smsg.set_crow(self.current_row)		

		self.mif.sendMsg(self.source, 0xFFFF, smsg.get_amType(), 0, smsg)
	
	# Called by the MoteIF's receive thread when a new message
	# is received
	def receive(self, src, msg):
		time.sleep(1)
		m = DecodedMsg(msg.dataGet())
		timeformat = '%Y/%d/%m %H:%M:%S'
		print 'Received message %s:' % time.strftime(timeformat)
		print ' true current row: ', self.current_row


		## get received data from mote
		rec_row = m.get_crow()
		print rec_row

		x_mote = np.array(m.get_V_coeff())
		#x_mote = x_mote[0:self.current_row+1]


		print 'mote result: ', x_mote

		#print 'selfsym ' , self.sym

		

		## check functionality in python

		V = self.A[:self.current_row+1,:]
		#change to same random thing?
		#V = np.asarray(self.rndV[1:,:])
		#also update symbols each time based on new random coeffs
		#self.sym = V*self.data

		#print self.A[:self.current_row+1,:]
		#print 'V is'
		#print V

		#print 'symbols to python'
		#print self.sym[:self.current_row+1]
		#print 'symbols over the air'
		#print self.rndSym
		#print self.sym2
		
		#U, S, W = np.linalg.svd(V.T)
		#print S
		Vnull = V[ :, [1,3,5,7] ]
		z = nullvec(Vnull.T)
		#ant_vec = np.mat('[0; 0; 0; 0; .1; 0; .2; 0]')
		ant_vec = np.multiply(np.mat('[0; 0; 1; 0; 1; 0; 1; 0]'), self.data)

		Vant = V*ant_vec
		
		#if len(z)>0:
			#print 'antidoteresult: ',z.T*Vant
		#else:			
			#print 'antidoteresult: ',[]

		if len(z)>0:
			#x_python = np.dot(z.T, V[:,0])
			#print x_python
			#print np.shape(z), np.shape(Vnull)
			#print np.matrix(Vnull).T*np.matrix(z)
			#print self.sym[0]
			#nulldata = z.T*self.sym[0]*np.ones((self.current_row+1,1))
			#print self.sym
			#print z.T
			#print self.sym[:self.current_row+1]
			nulldata = z.T*self.sym[:self.current_row+1]
			antdata = z.T*Vant
			finalresult = nulldata - antdata
			maindimension = V[:,[0]]
			xdot = z.T*maindimension
			finalresult = (finalresult/xdot)
			print 'final Python result: ',finalresult

			
		else:
			print []
		#U,S,V = np.linalg.svd(Vnull.T)
		#print S

		self.current_row = (self.current_row + 1) % self.N
		if self.current_row == 0:
			self.A = make_A_matrix(self.N)
			self.sym = self.A*self.data
		self.send()


def make_A_matrix(N):
	A = np.random.randn(N,N)
	#B = np.matrix(np.random.randn(4,4))
	#U, s, W = np.linalg.svd(B)
	#s[-1] = 0
	#B = np.array(U*np.diag(s)*W)

	
	#A[0:4,1] = B[:,0]
	#A[0:4,3] = B[:,1]
	#A[0:4,5] = B[:,2]
	#A[0:4,7] = B[:,3]
	print A

	return A

def nullvec(X, tol=1e-5):
	if np.shape(X)[0] == 0:
		V = np.eye(np.shape(X)[1])
	else:
		(U, s, Vt) = np.linalg.svd(X)
		V = Vt.T
	if np.shape(X)[1] > np.shape(X)[0]:
		z = V[:, -1]
	else:
		s = s < tol
		if np.any(s):
			z = V[:, s]
		else:
			z = []
	return np.matrix(np.array(z).reshape(-1, 1))

if __name__ == "__main__":
	print "Running"
	np.set_printoptions(precision=3)
	np.set_printoptions(suppress=True)

	if len(sys.argv) > 1:
		N = int(sys.argv[1])
	else:
		N  = 6
	m = MyClass(N)
	time.sleep(1)
	m.initialSend() #??? fails right now
	time.sleep(1)
	m.send()
