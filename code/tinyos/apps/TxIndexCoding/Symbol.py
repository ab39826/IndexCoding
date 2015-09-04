import numpy as np

class Symbol:
	def __init__(self, v_coeffs, msg_vals, msg_inds):
		self.v_coeffs = np.copy(v_coeffs)
		self.val = np.dot(v_coeffs, msg_vals)
		self.msg_inds = np.copy(msg_inds)
