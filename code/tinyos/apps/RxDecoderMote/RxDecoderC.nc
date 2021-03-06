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
	//uint8_t interf_vec[I] = {2,3,4,5,6,7}; // I interference dimensions, pass to mote instead of harcode?
	
	//int ant_vec[A] = {1}; //antidote dimensions, pass to mote instead of hardcode?
	//int Atable[N] = {0,1,3,2,5,4,7,6};
	
	// put this back in for 8 mote setup
	int Atable[N] = {0,1,2,3,4,5,6,7};
	int Desired_Table[N] = {1,0,3,2,5,4,7,6};
	
	//4motesetup
	/*int Atable[N] = {0,1,2,3};
	int Desired_Table[N] = {1,0,3,2};*/
	
	//12motesetup
	/*int Atable[N] = {0,1,2,3,4,5,6,7,8,9,10,11};
	int Desired_Table[N] = {1,0,3,2,5,4,7,6,9,8,11,10};*/

	//16motesetup
	//int Atable[N] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
	//int Desired_Table[N] = {1,0,3,2,5,4,7,6,9,8,11,10,13,12,15,14};
	
	
	//hard code for now, theres probably a better way, or just put in header file?
	int ant_vec[A];
	//setdiff between 0:N-1 and {ant_vec TOS_NODE_ID}
	//int interfTable[N][I];
	uint8_t interf_vec[I];
	
	//put this back in for 8 mote setup
	uint8_t interfTable0[I] = {2,3,4,5,6,7};
	uint8_t interfTable1[I] = {2,3,4,5,6,7};
	uint8_t interfTable2[I] = {0,1,4,5,6,7}; 
	uint8_t interfTable3[I] = {0,1,4,5,6,7}; 
	uint8_t interfTable4[I] = {0,1,2,3,6,7};
	uint8_t interfTable5[I] = {0,1,2,3,6,7};
	uint8_t interfTable6[I] = {0,1,2,3,4,5};
	uint8_t interfTable7[I] = {0,1,2,3,4,5};
	
	//4motesetup
	/*uint8_t interfTable0[I] = {2,3};
	uint8_t interfTable1[I] = {2,3};
	uint8_t interfTable2[I] = {0,1}; 
	uint8_t interfTable3[I] = {0,1};*/

	//12motesetup
	
	//uint8_t interfTable0[I] = {2,3,4,5,6,7,8,9,10,11};
	//uint8_t interfTable1[I] = {2,3,4,5,6,7,8,9,10,11};
	//uint8_t interfTable2[I] = {0,1,4,5,6,7,8,9,10,11}; 
	//uint8_t interfTable3[I] = {0,1,4,5,6,7,8,9,10,11}; 
	//uint8_t interfTable4[I] = {0,1,2,3,6,7,8,9,10,11};
	//uint8_t interfTable5[I] = {0,1,2,3,6,7,8,9,10,11};
	//uint8_t interfTable6[I] = {0,1,2,3,4,5,8,9,10,11};
	//uint8_t interfTable7[I] = {0,1,2,3,4,5,8,9,10,11};
	//uint8_t interfTable8[I] = {0,1,2,3,4,5,6,7,10,11};
	//uint8_t interfTable9[I] = {0,1,2,3,4,5,6,7,10,11};
	//uint8_t interfTable10[I] = {0,1,2,3,4,5,6,7,8,9};
	//uint8_t interfTable11[I] = {0,1,2,3,4,5,6,7,8,9};
		
	
	//16motesetup
	//uint8_t interfTable0[I] = {2,3,4,5,6,7,8,9,10,11,12,13,14,15};
	//uint8_t interfTable1[I] = {2,3,4,5,6,7,8,9,10,11,12,13,14,15};
	//uint8_t interfTable2[I] = {0,1,4,5,6,7,8,9,10,11,12,13,14,15}; 
	//uint8_t interfTable3[I] = {0,1,4,5,6,7,8,9,10,11,12,13,14,15}; 
	//uint8_t interfTable4[I] = {0,1,2,3,6,7,8,9,10,11,12,13,14,15};
	//uint8_t interfTable5[I] = {0,1,2,3,6,7,8,9,10,11,12,13,14,15};
	//uint8_t interfTable6[I] = {0,1,2,3,4,5,8,9,10,11,12,13,14,15};
	//uint8_t interfTable7[I] = {0,1,2,3,4,5,8,9,10,11,12,13,14,15};
	//uint8_t interfTable8[I] = {0,1,2,3,4,5,6,7,10,11,12,13,14,15};
	//uint8_t interfTable9[I] = {0,1,2,3,4,5,6,7,10,11,12,13,14,15};
	//uint8_t interfTable10[I] = {0,1,2,3,4,5,6,7,8,9,12,13,14,15};
	//uint8_t interfTable11[I] = {0,1,2,3,4,5,6,7,8,9,12,13,14,15};
	//uint8_t interfTable12[I] = {0,1,2,3,4,5,6,7,8,9,10,11,14,15};
	//uint8_t interfTable13[I] = {0,1,2,3,4,5,6,7,8,9,10,11,14,15};
	//uint8_t interfTable14[I] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
	//uint8_t interfTable15[I] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};


	float zvresult[N]; //might be able to overwrite something else.
	float antresult[PIECES];

	float main_dimension[N]; // size l<=N, but allocate beforehanded 
	//float known_data[A][PIECES];
	float **known_data;
	float nulldata_result[PIECES];
	float x;
	int trans = 0;
	int crowMem = 1;

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
  
	//UNCOMMENT ALL OF THIS NOW??
	event void MilliTimer.fired() {
		//int i = 0;
		//if (!locked) {
		//ack_msg_t* acm;
		//
		//acm =	(ack_msg_t*) (call RadioPacket.getPayload(&ackpacket,sizeof (ack_msg_t)));
		//acm->nodeid = TOS_NODE_ID;
		//acm->current_transmission = trans;
		//acm->ack_type = 1; 
		//
		//if (call RadioSend.send(AM_ACK_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
		////if (call RadioSend.send(100, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) { //broadcast instead??
		////if (call RadioSend.send(AM_BROADCAST_ADDR, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
		//locked = TRUE;
		call Leds.led2Toggle();
		//}
		//}

	}

	//if crow is negative, receive initial setup row (-1 want, 0 antidote, 1 interference) from V_coeff?
	//what about getting the known data??
	event message_t* RadioReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
		int i = 0,j=0,  success = FALSE;
		float tol = .001;
		//call Leds.led0Toggle();
		//if (len != sizeof(ack_msg_t)) { //Rx To Rx TEST
		if (len != sizeof(symbol_msg_t)) { 
			//call Leds.led0Toggle();
			return bufPtr;
			//call Leds.set(7);
		}
		else {		
			//call Leds.led2Toggle();
			symbol_msg_t* rcm = (symbol_msg_t*)payload;			
			ack_msg_t* acm;
			trans = rcm->current_transmission;
			//every mote gets this far every transmission
			//call Leds.led1Toggle();
			//call Leds.set(4);
				//????
			//TDMA MODE
			//if(TOS_NODE_ID == 7){call Leds.set(7);} //true for mote 7
			//if(rcm->messageid == 0){call Leds.set(7);} //always true?
			//if(rcm->messageid == 1){call Leds.set(7);} //never true
			if(rcm->messageid == TOS_NODE_ID){ //cannot be <0 or >N?	
				//call Leds.led1Toggle();
				for(i = 0; i<A; ++i){	
					for(j = 0; j<PIECES; ++j){
						known_data[i][j] = rcm->data[j]; //pass to mote instead of hardcode, is this only called once right now??
					}
				}
				//ALSO SEND ACKS HERE!!!!, better way to code?
				if (!locked) {
					acm =	(ack_msg_t*) (call RadioPacket.getPayload(&ackpacket,sizeof (ack_msg_t)));
					acm->nodeid = TOS_NODE_ID;
					acm->current_transmission = trans;
					acm->ack_type = 1; 
		
					if (call RadioSend.send(AM_ACK_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
					//if (call RadioSend.send(AM_BROADCAST_ADDR, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
						locked = TRUE;
						call Leds.led1Toggle();
					}
				}
				//reinitialze everything for next setup
				//let current row go up to 2N
					for (i = 0; i < crowMem*N; ++i) {
						for (j = 0; j < N; ++j) {
							V[i][j] = 0;
							W[i][j] = 0;
							V_null_tr[j][i] = 0;

					}
				}

				current_row = 0;
					
				return bufPtr;
			}	
			
			else { 
				//INDEX MODE
				if (rcm->messageid == 255) {

					if(current_row == crowMem*N){
						current_row = 0;
						for (i = 0; i < crowMem*N; ++i) {
							for (j = 0; j < N; ++j) {
								V[i][j] = 0;
								V_null_tr[j][i] = 0;
							}
						}
					}
							
				//	current_row = rcm->crow;	
					for (j = 0; j < N; ++j) {
						V[current_row][j] = rcm->V_coeff[j]; //adds another row to coefficient matrix
					}
			
		
					for(i =0; i<PIECES; ++i){	
						received_data[current_row][i] = rcm->data[i]; //fills received data completely with data
					}
			
					//column of data that this mote wants
					//main_dimension[current_row]= V[current_row][0];//assuming in column zero for now
					main_dimension[current_row]= V[current_row][Desired_Table[TOS_NODE_ID]];//assuming in column zero for now
			
			
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
			
					//success = null_vec(V_null_tr,I, current_row +1, S,(.0001),W,rv1);
				   success = null_vec(V_null_tr,crowMem*N, current_row +1, S,(.0001),W,rv1); //now svd wont fail
				
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
		
				}

				else {
					//neither TDMA nor index, another motes tdma, toggle led0?
					call Leds.led0Toggle();
					//if random case, also store side info here
					decode_status = FALSE;
				}


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
							call Leds.led1Toggle();
							}
						else {
							//for (i = 0; i < N; ++i) {
							acm->ack_type = 0;// means couldn't decode or different TDMA
							call Leds.led0Toggle();
							//know at this stage was not able to decode. So set up ack struct 
							//}
						}
						if (call RadioSend.send(AM_ACK_MSG, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
						//if (call RadioSend.send(AM_BROADCAST_ADDR, &ackpacket, sizeof(ack_msg_t)) == SUCCESS) {
							locked = TRUE;
						}
					}
				}

				//else {
				////call Leds.set(7);
				//}

			if (rcm->messageid == 255) { //only for index mode, to be safe?
				++current_row;
			}

			return bufPtr;

						//else {
						////neither TDMA nor index, another motes tdma, toggle led0?
						//acm->ack_type = 0;// means couldn't decode
						//call Leds.led0Toggle();
						//
						//return bufPtr;
				}
						//}

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
			//interfTable[0] = {2,3,4,5,6,7};
			//interfTable[1] = {2,3,4,5,6,7};
			//interfTable[2] = {0,1,4,5,6,7}; 
			//interfTable[3] = {0,1,4,5,6,7}; 
			//interfTable[4] = {0,1,2,3,6,7};
			//interfTable[5] = {0,1,2,3,6,7};
			//interfTable[6] = {0,1,2,3,4,5};
			//interfTable[7] = {0,1,2,3,4,5};
			//kluge but oh well
			ant_vec[0] = Atable[TOS_NODE_ID];
			//ant_vec[0] = Atable[0];

//			stupid and annoying but cant be anywhere else
			//change depending on number of motes
			if (TOS_NODE_ID==0) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable0[j];
				}
			}
			if (TOS_NODE_ID==1) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable1[j];
				}
			}
			if (TOS_NODE_ID==2) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable2[j];
				}
			}
			if (TOS_NODE_ID==3) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable3[j];
				}
			}			
			if (TOS_NODE_ID==4) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable4[j];
				}
			}
			if (TOS_NODE_ID==5) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable5[j];
				}
			}
			if (TOS_NODE_ID==6) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable6[j];
				}
			}
			if (TOS_NODE_ID==7) {
				for (j=0; j<I; j++) {
					interf_vec[j] = interfTable7[j];
				}
			}	
			//if (TOS_NODE_ID==8) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable0[j];
				//}
			//}
			//if (TOS_NODE_ID==9) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable1[j];
				//}
			//}
			//if (TOS_NODE_ID==10) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable2[j];
				//}
			//}
			//if (TOS_NODE_ID==11) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable3[j];
				//}
			//}
			//if (TOS_NODE_ID==12) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable4[j];
				//}
			//}
			//if (TOS_NODE_ID==13) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable5[j];
				//}
			//}
			//if (TOS_NODE_ID==14) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable6[j];
				//}
			//}
			//if (TOS_NODE_ID==15) {
				//for (j=0; j<I; j++) {
					//interf_vec[j] = interfTable7[j];
				//}
			//}		
			//crowMem necessary anymore??
			W = Make2DFloatArray(crowMem*N, N);
			V = Make2DFloatArray(crowMem*N, N);
			V_null_tr = Make2DFloatArray(N, crowMem*N);
			received_data = Make2DFloatArray(crowMem*N,PIECES);
			
			known_data = Make2DFloatArray(A,PIECES);
			for (i = 0; i < crowMem*N; ++i) {
				for (j = 0; j < N; ++j) {
					W[i][j] = 0;
					V[i][j] = 0;
					V_null_tr[j][i] = 0;
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

