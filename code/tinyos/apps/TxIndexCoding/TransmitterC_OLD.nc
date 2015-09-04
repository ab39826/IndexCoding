#include <Timer.h>
#include "Transmitter.h"

module TransmitterC {
	uses{
		interface Boot;
		interface SplitControl as RadioControl;
		interface SplitControl as SerialControl;
		interface Leds;
		interface Timer<TMilli> as Timer0; 

		interface AMSend as UartSend;
		// interface Receive as UartReceive;
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
	/*uint8_t index =0;*/
	uint32_t current_transmission = 0;
	//uint32_t current_round = 0;
	/*uint8_t currentmessage = 0; //default to having receiver 0 getting first message  */
	event void Boot.booted() {
		call SerialControl.start();  
	}

	// Main routine - triggers every time Timer0 ticks
	event void Timer0.fired() {
		uint8_t i;

		// every time the (slow) clock ticks, we gather all the ACKS
		// 	if an ACK was not received from RX_i, set to type 0
		//		use the ACKS to build R[N] (column of received symbols as in the simulation)
		//		send R[N] to Host (or just send ACKs[N], TBD)
		//	every time we receive a tx_serial_msg (indicates Host has computed next transmission),
		//		we send out the new symbol_msg transmission and wait to hear back our ACKS

		// clock has ticked. send ACKs to host whether or not receivers are done processing
		if (!locked) {
			target_to_host_msg_t* t2hpkt = (target_to_host_msg_t*) (call RadioPacket.getPayload(&serialpkt, sizeof (target_to_host_msg_t)));
			for (i = 0; i < N; ++i) {
				t2hpkt->ACKs[i] = ACKs[i];
			}
			
			//t2hpkt->round = current_round;
			t2hpkt->transmission = current_transmission;

			call Leds.led0Toggle(); // clock tick heartbeat

			if (call UartSend.send(t2hpkt->transmission, &serialpkt, sizeof(target_to_host_msg_t)) == SUCCESS) {
				call Leds.led2Toggle();
				locked = TRUE;
			}
		}
	}

	event void RadioControl.startDone(error_t err) {
		uint8_t i;
		if (err != SUCCESS) {
			call RadioControl.start();
		}
		else {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
			// initialize ACKs array 
			for(i = 0; i < N; ++i) {
				ACKs[i] = 0;
			}
		}
	}

	event void SerialControl.startDone(error_t err) {
		if( err != SUCCESS) {
			call SerialControl.start();
		}
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
		if (&serialpkt == bufPtr){
			locked = FALSE;
		}
	}

	event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
		uint8_t id, ack_type;
		 
		// check which type of packet was received TYPOS????!
/*		if (len == sizeof(ack_msg)) { // ack_msg
			ack_msg* ackpkt = (ack_msg*)payload; //unpacks the message*/
		//CORRECT??
		if (len == sizeof(ack_msg_t)) {
			ack_msg_t* ackpkt = (ack_msg_t*)payload; //unpacks the message	
			id = ackpkt->nodeid;
			ack_type = ackpkt->ack_type;
			// set ACKs[id] to the received ack. It may still be zero, which is OK
			// Is current_transmission needed? is it the same as crow?
			if (ackpkt->current_transmission == current_transmission && ACKs[id] == 2) {
				ACKs[id] = ack_type;
			}
			call Leds.led1Toggle(); //heartbeat
		}

		return msg;
	}

	//event message_t* SerialReceive.receive(message_t* msg, void * payload, uint8_t len){
	/*
		uint8_t nodenum;
		uint32_t rounds;
		uint32_t trans;

		if( len != sizeof(serial_msg)) {return msg;}
		else{
		serial_msg* rcm = (serial_msg*)payload;

		nodenum = rcm->num_nodes;
		rounds = rcm->num_rounds;
		trans = rcm->num_transmissions;

		}
		*/

	//}	
}
