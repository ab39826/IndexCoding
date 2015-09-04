#include "Timer.h"
#include "RxDecoder.h"

module RxDecoderC {
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface Leds;
		interface Timer<TMilli> as MilliTimer;


		interface AMSend as RadioSend;
		interface Receive as RadioReceive;
		interface Packet as RadioPacket;
		interface AMPacket as RadioAMPacket;
	}
//uses interface matches up with TDMAReceiver. Millitimer isn't used so doesn't matter.
}
implementation {

	//uint16_t data_array[N][L];
	message_t packet;
	message_t ackpacket;

	bool locked = FALSE, decode_status = FALSE;
	uint8_t current_row = 0;
	float ** W; // row space of V_null_tr
	float * S;  // singular values of V_null_tr, overwritten by null vector
	float ** V; // linear combinations matrix
	float ** V_null_tr; // interference submatrix
	float ** received_data; //size [N][B]
	float rv1[N]; // internal storage for svd
	uint8_t interf_vec[I] = {2,3,4,5,6,7}; // I interference dimensions, pass to mote instead of harcode?
	
	int ant_vec[A] = {1}; //antidote dimensions, pass to mote instead of hardcode?
	float zvresult[N]; //might be able to overwrite something else.
	float antresult[PIECES];

	float main_dimension[N]; // size l<=N, but allocate beforehanded 
	//float known_data[A][PIECES];
	float **known_data;
	float nulldata_result[PIECES];
	float x;
	int trans = 0;

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
		call RadioControl.start();
	}
  
	event void MilliTimer.fired() {
	//int i = 0;
	if (!locked) {
	ack_msg_t* acm;
	
	acm =	(ack_msg_t*) (call RadioPacket.getPayload(&ackpacket,sizeof (ack_msg_t)));
	acm->nodeid = TOS_NODE_ID;
	acm->current_transmission = trans;
	acm->ack_type = 1; 
	
	//if (call RadioSend.send(AM_ACK_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
	//if (call RadioSend.send(AM_SYMBOL_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) { //just try this
	//if (call RadioSend.send(AM_BROADCAST_ADDR, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) { //broadcast instead??
		if (call RadioSend.send(100, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) { //broadcast instead??
		locked = TRUE;
		call Leds.led1Toggle();
	}
	}

	}

	//if crow is negative, receive initial setup row (-1 want, 0 antidote, 1 interference) from V_coeff?
	//what about getting the known data??
	event message_t* RadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		int i = 0,j=0,  success = FALSE;
		float tol = .001;
		//call Leds.led0Toggle();
		if (len != sizeof(ack_msg_t)) { //Rx To Rx TEST
			//if (len != sizeof(symbol_msg_t)) { 
			call Leds.led0Toggle();
			return bufPtr;
			//call Leds.set(7);
		}
		else {		
			//call Leds.led2Toggle();
			symbol_msg_t* rcm = (symbol_msg_t*)payload;			
			ack_msg_t* acm;
			trans = rcm->current_transmission;
			call Leds.led2Toggle();
			//call Leds.set(4);
				//????
			if(rcm->messageid == TOS_NODE_ID){ //cannot be <0 or >N?	
				for(i = 0; i<A; ++i){	
					for(j = 0; j<PIECES; ++j){
						known_data[i][j] = rcm->data[j]; //pass to mote instead of hardcode, is this only called once right now??
					}
				}
				//continue //syntax error??
				return bufPtr;
			}	
				
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
				//call Leds.led1Toggle();	
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
				//call Leds.led2Toggle();
				//rcm = (decoded_msg_t*)call Packet.getPayload(&packet, sizeof(decoded_msg_t));
				//ack_msg_t* acm = (ack_msg_t*) payload;
				//ack_msg_t* acm;
				acm =	(call RadioPacket.getPayload(&ackpacket,sizeof (ack_msg_t)));
				acm->nodeid = TOS_NODE_ID;
				acm->current_transmission = trans;

				
				if ((acm != NULL) && (call RadioPacket.maxPayloadLength() >= sizeof(ack_msg_t))) {
					//call Leds.led0Toggle();
						//decode_status = TRUE;
				
					if (decode_status) {
						// send a different message
						//for (i = 0; i < PIECES; ++i) {
							
						//	rcm->V_coeff[i] = S[i];
							
								acm->ack_type = 1;	//means decoded

					
							
							//ORDER FOR TESTING WITH PYTHON
							//first check x (1x1) coefficient in null vector corresponding to receiver's message
							//next check nulldata_result (1xB) containing null vector times symbol matrix S. comment out some stuff because you overwrite this later
							// then check zvresult (1xN) null vector times V
							// then check antresult (1xB) containing Z*V*A all fine and dandy up to here
							// finally check new nulldata_result (1xB) your answer in pieces
				
						//}
					}
					else {
						//for (i = 0; i < N; ++i) {
							acm->ack_type = 0;// means couldn't decode
							//know at this stage was not able to decode. So set up ack struct 
						//}
					}
					if (call RadioSend.send(AM_ACK_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
						locked = TRUE;
					}
				}
			}
			else {
				//call Leds.set(7);
			}

			++current_row;
			return bufPtr;
		}
	}

	event void RadioSend.sendDone(message_t* bufPtr, error_t error) {
		if (&ackpacket == bufPtr) {
			locked = FALSE;
		}
	}

	event void RadioControl.startDone(error_t err) {
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
					known_data[i][j] = i/1.0; //pass to mote instead of hardcode, is this only called once right now??
				}
			}

			for (i = 0; i<N; ++i){
				for(j = 0; j<PIECES; ++j){
					received_data[i][j] = 0;
				}
			}
			//call Leds.set(4);
			//rv1 = (float*)malloc((unsigned int) N*sizeof(float));
			S = (float*) malloc(N*sizeof(float));  
			call MilliTimer.startPeriodic(TIMER_PERIOD);
		}
	}
	event void RadioControl.stopDone(error_t err)
	{

	}
}

