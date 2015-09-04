#include "Timer.h"
#include "RxDecoder.h"

module RxDecoderC {
	uses {
		interface SplitControl as Control;
		interface Leds;
		interface Boot;
		interface Receive;
		interface AMSend;
		interface Timer<TMilli> as MilliTimer;
		interface Packet;
	}
}
implementation {

	//uint16_t data_array[N][L];
	message_t packet;

	bool locked = FALSE;
	uint16_t counter = 0;
	uint8_t perform_svd = 0;
	float ** A;
	float * S2;
	float ** V;
	double rv1[N];

	int null_vec(float **X, int l, int n, float *z, float tol) {
		float null_tol = 0.0001;
		int success = FALSE, svd_success = FALSE; // guilty until proven innocent
		int i = 0, j = 0;
		// allocate memory for S and V
		float *S = (float*) malloc(l*sizeof(float));
		float **V = Make2DFloatArray(n, n);
		
		// perform SVD on matrix X
		svd_success = dsvd(X, l, n, S, V, rv1);
		if (svd_success) {
			// check for null vector: go through S and find value less than tol
			for (i = 0; i < n; ++i) {
				if (S[i] < null_tol) {
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

	float** Make2DFloatArray(int arraySizeX, int arraySizeY) {  
		int i;
		float** theArray;  
		theArray = (float**) malloc(arraySizeX*sizeof(float*));  
		for (i = 0; i < arraySizeX; ++i)  
			theArray[i] = (float*) malloc(arraySizeY*sizeof(float));  
		return theArray;  
		
		//
		//for (i = 0; i < nx; i++){  
			//free(myArray[i]);  
		//}  
	}   

	event void Boot.booted() {
		call Control.start();
	}
  
	event void MilliTimer.fired() {
		int n;
		int i = 0;
		int svd_return = 0;
		counter++;
		if (locked) {
			call Leds.set(1);
			return;
		}
		else {
			decoded_msg_t* rcm = (decoded_msg_t*)call Packet.getPayload(&packet, sizeof(decoded_msg_t));
			call Leds.set(7);
			if (rcm == NULL) {
				return;
			}
			if (call Packet.maxPayloadLength() < sizeof(decoded_msg_t)) {
				return;
			}

			rcm->counter = counter;
			rcm->perform_svd = perform_svd;
			if (perform_svd == N) {
				// perform SVD
				//svd(A, S2, N);
				n = N;
				svd_return = dsvd(A, N, N, S2, V, rv1);
				perform_svd = 0;
				for (i = 0; i < N; ++i) {
					rcm->A[i] = S2[i];
				}
			}
			else {
				for (i = 0; i < N; ++i) {
					rcm->A[i] = 0;
				}
			}
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(decoded_msg_t)) == SUCCESS) {
				locked = TRUE;
			}
		}
	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		int i = 0; //, j = 0;
		if (len != sizeof(decoded_msg_t)) {
			return bufPtr;
		}
		else {
			decoded_msg_t* rcm = (decoded_msg_t*)payload;
			//call Leds.set(counter);
			perform_svd = rcm->perform_svd;
			if (perform_svd) {
				for (i = 0; i < N; ++i) {
					A[perform_svd-1][i] = rcm->A[i];
				}
			}


			return bufPtr;
		}
	}

	event void AMSend.sendDone(message_t* bufPtr, error_t error) {
		if (&packet == bufPtr) {
			locked = FALSE;
		}
	}

	event void Control.startDone(error_t err) {
		uint8_t i = 0, j = 0;
		if (err == SUCCESS) {
			A = Make2DFloatArray(N, N);
			V = Make2DFloatArray(N, N);
			for (i = 0; i < N; ++i) {
				for (j = 0; j < N; ++j) {
					A[i][j] = 0;
				}
			}
			//rv1 = (double*)malloc((unsigned int) N*sizeof(double));
			S2 = (float*) malloc(N*sizeof(float));  
			call MilliTimer.startPeriodic(TIMER_PERIOD);
		}
	}
	event void Control.stopDone(error_t err)
	{

	}
}

