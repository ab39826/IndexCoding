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

	bool locked = FALSE, decode_status = FALSE;
	uint16_t counter = 0;
	uint8_t current_row;
	float ** W; // row space of V_null_tr
	float * S;  // singular values of V_null_tr, overwritten by null vector
	float ** V; // linear combinations matrix
	float ** V_null_tr; // interference submatrix
	float rv1[N]; // internal storage for svd
	uint8_t interf_vec[I] = {1, 3, 5, 7}; // I interference dimensions
	float main_dimension[N]; // size l<=N, but allocate beforehanded 

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
		int i = 0;
		counter++;
		//call Leds.set(counter);

	}

	event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		int i = 0,j=0,  success = FALSE;
		float tol = .001;
		if (len != sizeof(decoded_msg_t)) {
			return bufPtr;
		}
		else {
			decoded_msg_t* rcm = (decoded_msg_t*)payload;
			//call Leds.set(1);
			//call Leds.set(counter);
			current_row = rcm->current_row;
			for (i = 0; i < N; ++i) {
				V[current_row][i] = rcm->V_row[i];
			}
			main_dimension[current_row] = V[current_row][0];

			// try to decode
			// build V_null_tr (transpose)
			decode_status = TRUE;
			for (i = 0; i <= current_row; ++i) {
				for (j = 0; j < I; ++j) {
					V_null_tr[j][i] = V[i][interf_vec[j]];
				}
			}
			// try to find a null vector
			//success = null_vec(V_null_tr, I, current_row+1, S, tol, W, rv1);
			for (i = 0; i < N; ++i) {
				S[i] = 0;
			}
			//decode_status = svd(V_null_tr, I, current_row+1, S, W, rv1);
			
		   success = null_vec(V_null_tr,I, current_row+1, S,(.0001),W,rv1);
			
			if (success) {
				//// S contains the null vec
				//// make sure it doesn't interfere with desired message
				if (fabs(dotproduct(S, main_dimension, current_row+1)) > tol) {
					//// set decode_status to TRUE
					decode_status = TRUE;
				}
			}
			else{decode_status = FALSE;}
			// set decode status to TRUE for testing
			//success = svd(
		 //  decode_status = TRUE;
			//	decode_status = FALSE;
		





			
			if (!locked) {
				call Leds.set(decode_status);
				rcm = (decoded_msg_t*)call Packet.getPayload(&packet, sizeof(decoded_msg_t));
				if ((rcm != NULL) && (call Packet.maxPayloadLength() >= sizeof(decoded_msg_t))) {
					//call Leds.led0Toggle();

					rcm->counter = counter;
					rcm->current_row = current_row;
					if (decode_status) {
						// send a different message
						for (i = 0; i < N; ++i) {
							rcm->V_row[i] = S[i];
							
						}
					}
					else {
						for (i = 0; i < N; ++i) {
							rcm->V_row[i] = -1; //V[current_row][i];
						}
					}
					if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(decoded_msg_t)) == SUCCESS) {
						locked = TRUE;
					}
				}
			}
			else {
				call Leds.set(7);
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
			W = Make2DFloatArray(N, N);
			V = Make2DFloatArray(N, N);
			V_null_tr = Make2DFloatArray(N, N);
			for (i = 0; i < N; ++i) {
				for (j = 0; j < N; ++j) {
					W[i][j] = 0;
					V[i][j] = 0;
					V_null_tr[i][j] = 0;
				}
			}
			//rv1 = (float*)malloc((unsigned int) N*sizeof(float));
			S = (float*) malloc(N*sizeof(float));  
			call MilliTimer.startPeriodic(TIMER_PERIOD);
		}
	}
	event void Control.stopDone(error_t err)
	{

	}
}

