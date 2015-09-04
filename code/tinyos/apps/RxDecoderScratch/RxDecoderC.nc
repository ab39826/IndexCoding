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
	uint8_t current_row = 0;
	float ** W; // row space of V_null_tr
	float * S;  // singular values of V_null_tr, overwritten by null vector
	float ** V; // linear combinations matrix
	float ** V_null_tr; // interference submatrix
	float ** received_data; //size [N][B]
	float rv1[N]; // internal storage for svd
	uint8_t interf_vec[I] = {1, 3, 5, 7}; // I interference dimensions
	
	int ant_vec[A] = {2,4,6};
	float zvresult[N]; //might be able to overwrite something else.
	float antresult[PIECES];

	float main_dimension[N]; // size l<=N, but allocate beforehanded 
	//float known_data[A][PIECES];
	float **known_data;
	float nulldata_result[PIECES];
	float x;

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
	//int i = 0;
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

				if(current_row == N){
					current_row = 0;
				}
							
				current_row = rcm->crow;	
				for (j = 0; j < N; ++j) {
					V[current_row][j] = rcm->V_coeff[j]; //adds another row to coefficient matrix
				}
			
		
				for(i =0; i<PIECES; ++i){	

					received_data[current_row][i] = rcm->data[i]; //fills received data completely with data
				}
			
			main_dimension[current_row]= V[current_row][0];//assuming in column zero for now
			
			
			// try to decode
			// build V_null_tr (transpose)
			decode_status = TRUE;
			for (i = 0; i <= current_row; ++i) {
				for (j = 0; j < I; ++j) {
					V_null_tr[j][i] = V[i][interf_vec[j]];
				}
			}
			// try to find a null vector
			for (i = 0; i < N; ++i) {
				S[i] = 0;
			}
			//decode_status = svd(V_null_tr, I, current_row, S, W, rv1);
			
		   success = null_vec(V_null_tr,I, current_row +1, S,(.0001),W,rv1);
				
		//	success  = svd(V_null_tr, I, (current_row +1), S, W, rv1); // sanity check
			
			
					
			if (success) {
				//// S contains the null vec
				//// make sure it doesn't interfere with desired message
					
					x = dotproduct(S,main_dimension, current_row+1);		

				if (fabs(x) > tol) {
					//// set decode_status to TRUE
					decode_status = TRUE;
				}
			}
			else{decode_status = FALSE;}
			// set decode status to TRUE for testing
		
		


			//if null vector is good, need to multiply null vector by received data

			if(decode_status){
				
				vectormatrixmult(S,received_data,nulldata_result,current_row+1,PIECES);
				//nulldata_result is an array of size 1xB containining null vector times symbol matrix S.
			 	//// now need to get Z*V*A
				
				vectormatrixmult(S,V,zvresult,current_row+1,N);

				
		
				vectorantidotemult(zvresult, known_data, antresult, N, A, PIECES,ant_vec);

				for(i=0; i<PIECES; ++i){
					nulldata_result[i] = (nulldata_result[i]-antresult[i]); // antresult now contains non-normalized message, have to divide by coefficient in null vector
					nulldata_result[i] = (nulldata_result[i]/fabs(x));
				}
			
			}

			
			if (!locked) {
				call Leds.set(decode_status);
				rcm = (decoded_msg_t*)call Packet.getPayload(&packet, sizeof(decoded_msg_t));
				if ((rcm != NULL) && (call Packet.maxPayloadLength() >= sizeof(decoded_msg_t))) {
					//call Leds.led0Toggle();
						//decode_status = TRUE;
						rcm->crow = current_row;
					if (decode_status) {
						// send a different message
						for (i = 0; i < PIECES; ++i) {
							
						//	rcm->V_coeff[i] = S[i];
							
							rcm->V_coeff[i] = nulldata_result[i];

								//if(SUCCESS){
								//rcm->V_coeff[i] = 14;//sanity check
								//}

//if(!SUCCESS){
//rcm->V_coeff[i] = 28; // sanity check
//}
							
							//ORDER FOR TESTING WITH PYTHON

							//first check x (1x1) coefficient in null vector corresponding to receiver's message
							//next check nulldata_result (1xB) containing null vector times symbol matrix S. comment out some stuff because you overwrite this later
							// then check zvresult (1xN) null vector times V
							// then check antresult (1xB) containing Z*V*A all fine and dandy up to here
							// finally check new nulldata_result (1xB) your answer in pieces
							
							
							
						}
					}
					else {
						for (i = 0; i < N; ++i) {
							rcm->V_coeff[i] = -1; //V[current_row][i]
						
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

			++current_row;
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
			received_data = Make2DFloatArray(N,PIECES);
			known_data = Make2DFloatArray(A,PIECES);
			for (i = 0; i < N; ++i) {
				for (j = 0; j < N; ++j) {
					W[i][j] = 0;
					V[i][j] = 0;
					V_null_tr[i][j] = 0;
				}
			}
			
			for (i = 0; i<A; ++i){
				for(j = 0; j<PIECES; ++j){
					known_data[i][j] = 1;
				}
			}

			for (i = 0; i<N; ++i){
				for(j = 0; j<PIECES; ++j){
					received_data[i][j] = 0;
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

