from cvxpy import *                              # Import cvxpy

A = randn(50,5)                                  # Generate problem data
b = 20*randn(50,1)
G = randn(10,5)
h = 5*randn(10,1)
alpha = 60

x = variable(5,1)                                # Create optimization variable

p = program(minimize(norm2(A*x-b)),              # Create problem instance
			 [leq(norm1(G*x-h),alpha),
			  geq(x,1)])

print p.solve(quiet=True)                              # Get optimal value

print x.value                
