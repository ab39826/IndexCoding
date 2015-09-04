#include "linalg.h"
#include "decode_msgs.h"

int null_vec(float **V_null_tr, int n, int l, float *z, float tol, float **W, float *rv1) {
	int success = FALSE, svd_success = FALSE; // guilty until proven innocent
	int i = 0, j = 0;
	
	// perform SVD on matrix X
	svd_success = svd(V_null_tr, n, l, z, W, rv1);
	if (svd_success) {
		// check for null vector: go through S and find value less than tol
		for (i = 0; i < l; ++i) {
			if (z[i] < tol) {
				success = TRUE;
				for (j = 0; j < n; ++j) {//originally l, changing to n because you got to fight for your right to party
					z[j] = W[j][i];
				}
				break;
			}
		}
	}

  return success;	
}


