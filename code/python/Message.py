# Message.py

import numpy as np

class Symbol:
	"""A linear combination of Messages"""
	def __init__(self, coeffs, msgs):
		if type(msgs) is list:
			val = 0
			msg_inds = []
			for i in range(len(msgs)):
				val = val + coeffs[i]*msgs[i].val
				msg_inds.append(msgs[i].index)
		else:
			val = msgs.val
			msg_inds = [msgs.index]
			coeffs = [coeffs]
		self.coeffs = coeffs
		self.val = val
		self.msg_inds = msg_inds
	
	def __str__(self):
		s = ''
		for i in range(len(self.msg_inds)):
			s = s + '%.1f*W%s + ' % (self.coeffs[i], self.msg_inds[i])
		s = s.rstrip(' +')
		return s

	def __repr__(self):
		s = ''
		for i in range(len(self.msg_inds)):
			s = s + '%.1f*W%s + ' % (self.coeffs[i], self.msg_inds[i])
		s = s.rstrip(' +')
		return s

class Message:
	"""The col'th packet desired by the row'th receiver"""
	def __init__(self, row, col, val):
		self.index = [row, col]
		self.val = val

	def __str__(self):
		return "W[%d,%d]" % (self.index[0], self.index[1])
		#return "Message number %d for Receiver %d with value %f" % (self.index[1], self.index[0], self.val)
	def __repr__(self):
		return "W[%d,%d]" % (self.index[0], self.index[1])
		#return "Message number %d for Receiver %d with value %d" % (self.index[1], self.index[0], self.val)

# converts a matrix of numbers to a matrix of
# Messages with corresponding numbers as vals
def generate_messages(message_matrix):
	msgs = []
	for row in range(np.size(message_matrix,0)):
		msg_row = []
		for col in range(np.size(message_matrix,1)):
			msg_row.append(Message(row, col, message_matrix[row,col]))
		msgs.append(np.array(msg_row))
	return np.array(msgs)

# converts a matrix of Messages to Matrix of Symbols
# def generate_symbols(coeffs,Messages,num_nodes):
#        symbol_vec = []
#        for i in range(num_nodes):
#                coeffs_vec = coeffs[i,:].tolist()
#                msgs_vec = Messages[i,:].tolist()
#                symbol_vec.append(Symbol(coeffs_vec, msgs_vec))
#        return np.array(symbol_vec)
