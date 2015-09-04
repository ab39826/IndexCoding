#include "svd.h"
#include "decode_msgs.h"

int null_vec(float **X, int l, int n, float *z, float tol, float *rv1) {
	int success = FALSE, svd_success = FALSE; // guilty until proven innocent
	int i = 0, j = 0;
	// allocate memory for S and V
	float *S = (float*) malloc(l*sizeof(float));
	float **V = Make2DFloatArray(n, n);
	float tol = 0.0001;
	
	// perform SVD on matrix X
	svd_success = svd(X, l, n, S, V, rv1);
	if (svd_success) {
		// check for null vector: go through S and find value less than tol
		for (i = 0; i < n; ++i) {
			if (S[i] < tol) {
				success = TRUE;
				for (j = 0; j < n; ++j) {
					z[j] = V[i][j];
				}
				break;
			}
		}
	}

	free(V);
	free(S);

  return success;	
}
