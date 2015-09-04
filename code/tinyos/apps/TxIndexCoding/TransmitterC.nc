#include <Timer.h>
#include "Transmitter.h"

module TransmitterC {
	uses{
		interface Boot;
		interface SplitControl as RadioControl;
		interface SplitControl as SerialControl;
		interface Leds;
		interface Timer<TMilli> as Timer0; 

		//duplicates???  only 1 receive and check based on length?
		interface AMSend as UartSend;
		interface Receive as UartReceive;
		interface Packet as UartPacket;
		interface AMPacket as UartAMPacket;

		interface AMSend as RadioSend;
		interface Receive as RadioReceive;
		interface Packet as RadioPacket;
		interface AMPacket as RadioAMPacket; //dont think I need this.

	}
}

implementation {
	bool busy = FALSE; //only one needed?
	bool locked = FALSE;
	message_t radiopkt;
	message_t serialpkt;
	uint8_t ACKs[N] = {2};
	//uint8_t n = 0;
	/*uint8_t index =0;*/
	uint32_t current_transmission = 0;
	//uint32_t trans = 0;
	//uint32_t current_round = 0;
	/*uint8_t currentmessage = 0; //default to having receiver 0 getting first message  */
	event void Boot.booted() {
		call SerialControl.start();  
	}

	//Main routine - triggers every time Timer0 ticks STAYS IN HERE FOREVER??
	event void Timer0.fired() {
		uint8_t i;
		//n = n+1;

		// every time the (slow) clock ticks, we gather all the ACKS
		// 	if an ACK was not received from RX_i, set to type 0
		//		use the ACKS to build R[N] (column of received symbols as in the simulation)
		//		send R[N] to Host (or just send ACKs[N], TBD)
		//	every time we receive a tx_serial_msg (indicates Host has computed next transmission),
		//		we send out the new symbol_msg transmission and wait to hear back our ACKS

		// clock has ticked. send ACKs to host whether or not receivers are done processing
		if (!locked) {
			//target_to_host_msg_t* t2hpkt = (target_to_host_msg_t*) (call RadioPacket.getPayload(&serialpkt, sizeof (target_to_host_msg_t)));
			target_to_host_msg_t* t2hpkt = (target_to_host_msg_t*) (call UartPacket.getPayload(&serialpkt, sizeof (target_to_host_msg_t)));
			for (i = 0; i < N; ++i) {
				t2hpkt->ACKs[i] = ACKs[i]; //set to counter instead to avoid receiver
				//t2hpkt->ACKs[i] = 1;
				//t2hpkt->ACKs[i]=current_transmission;
			}

			//t2hpkt->round = current_round;
			t2hpkt->transmission = current_transmission;
			//t2hpkt->transmission = current_transmission + 20; //just to check can modify

			call Leds.led0Toggle(); // clock tick heartbeat

			//if (call UartSend.send(AM_T2H_MSG, &serialpkt, sizeof(target_to_host_msg_t)) == SUCCESS) {
			if (call UartSend.send(AM_TARGET_TO_HOST_MSG, &serialpkt, sizeof(target_to_host_msg_t)) == SUCCESS) {
				//call Leds.led2Toggle();
				locked = TRUE;
			}
		}
		//return msg;
	}

	event void RadioControl.startDone(error_t err) {
		uint8_t i;
		if (err != SUCCESS) {
			call RadioControl.start();
		}
		else {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
			// initialize ACKs array at each round, DOES NOT GET CALLED EACH ROUND! 
			for(i = 0; i < N; ++i) {
				ACKs[i] = 2; //stuck at this in index coding mode??
			}
			//call Leds.led1Toggle(); //heartbeat
			//maybe this will help??
			call SerialControl.start();
		}
	}

	event void SerialControl.startDone(error_t err) {
		if( err != SUCCESS) {
			call SerialControl.start();
		}
		//call Leds.led1Toggle();
		call RadioControl.start();
	}

	event void RadioControl.stopDone(error_t err) {} 
	event void SerialControl.stopDone(error_t err) {}

	event void RadioSend.sendDone(message_t* msg, error_t error) {
		if (&radiopkt == msg) {
			busy = FALSE;
		}
	}

	event void UartSend.sendDone(message_t* bufPtr, error_t error) {
		uint8_t i;
		if (&serialpkt == bufPtr){
			locked = FALSE;
			//also reset ACKs array here??
			for(i = 0; i < N; ++i) {
				ACKs[i] = 2; //stuck at this index coding mode??
			}
		}
	}

	//record ACK when receiver message arrives
		event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
			if (!locked) { //no difference, but is this useful anyway?
				uint8_t id, ack_type;
				//call Leds.led2Toggle();
				// check which type of packet was received
				if (len == sizeof(ack_msg_t)) {
					ack_msg_t* ackpkt = (ack_msg_t*)payload; //unpacks the message	
					call Leds.led2Toggle();
					id = ackpkt->nodeid;
					ack_type = ackpkt->ack_type;
					// set ACKs[id] to the received ack. It may still be zero, which is OK
					// Is current_transmission needed? use round and current_transmission but not crow?
					// simulate all acks until use with a receiver?
					//if (ackpkt->current_transmission == current_transmission && ACKs[id] == 2) {
					if (ACKs[id] == 2) {
						ACKs[id] = ack_type;
					}
					//call Leds.led1Toggle(); //heartbeat
				}

				//else { //from host
				//if (len == sizeof(tx_serial_msg_t)) { //from host
				//tx_serial_msg_t* rcm = (tx_serial_msg_t*)payload;
				//
				////mid = rcm->messageid;
				//mid = 28;
				////rounds = rcm->num_rounds;
				//current_transmission = rcm->current_transmission;
				//call Leds.led1Toggle();	
				////send to a mote, set locked to true	
				//}
				//}

			}
			return msg;	
		}
	
	//transmit message from host over the air, serial/uart receive different from radio receive?
	//IS THIS NEEDED NOW THAT APPC HAS CHANGED??
			event message_t* UartReceive.receive(message_t* bufPtr, void * payload, uint8_t len){	
				int i=0, j=0;
				//uint8_t mid;
				//uint32_t rounds;
				//uint8_t current_row;
				//float dat;
				//float Vc;
				//uint32_t trans; //uint16 or 8 instead?
				//call Leds.led1Toggle();
				if( len != sizeof(tx_serial_msg_t)) {return bufPtr;}
				else{
					tx_serial_msg_t* rcm = (tx_serial_msg_t*)payload;
					//try direct assignment without intermediate variables?
					//symbol_msg_t* airpkt = (symbol_msg_t*) (call UartPacket.getPayload(&radiopkt, sizeof (symbol_msg_t)));
					symbol_msg_t* airpkt = (symbol_msg_t*) (call RadioPacket.getPayload(&radiopkt, sizeof (symbol_msg_t)));
					//mid = rcm->messageid;
					//rounds = rcm->num_rounds;
					//current_row = rcm->crow;
					current_transmission = rcm->current_transmission; //this lags behind?, keep because it is used later, only keep this and round for checking?
					airpkt->messageid = rcm->messageid;
					//airpkt->crow = rcm->crow;
					airpkt->current_transmission = current_transmission;
					//loop through coeff N and data pieces
					for (i=0; i<PIECES; i++) {
						//dat = rcm->data[i];
						//airpkt->data[i] = dat;
						airpkt->data[i] = rcm->data[i];
					}
					for (j=0; j<N; j++) {
						//Vc = rcm->V_row[j];
						//airpkt->V_coeff[j] = Vc;
						airpkt->V_coeff[j] = rcm->V_row[j];
					}	


					//COMMENT THIS FOR OVER THE AIR RECEPTION
					//edit the acks in here for now, CHANGE LATER, when run twice, this does not get reinitialized to 2
					//if (rcm->messageid == 255) {
					//for (j=0; j<N; j+=2) {
					////for (j=0; j<N; j++) {
					//ACKs[j] = 1;
					//}
					//}
					//else {
					//ACKs[rcm->messageid] = 1;
					//}
					//call Leds.led1Toggle();
					//call RadioSend
					//CHANGE BACK TO NOT BROADCAST??
					//FAILS IF NOT SET TO BROADCAST
					//if (call RadioSend.send(AM_SYMBOL_MSG, &radiopkt, sizeof(symbol_msg_t)) == SUCCESS) {	
					if (call RadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(symbol_msg_t)) == SUCCESS) {
						//call Leds.led2Toggle();
						call Leds.led1Toggle();
						busy = TRUE;
					}

					return bufPtr;
				}	
				}
			}
