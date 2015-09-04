 #include <Timer.h>
 #include "BlinkToRadioReceiver.h"

 module BlinkToRadioReceiverC {
        uses interface Boot;
        uses interface Leds;
        uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
 }

implementation {
   bool busy = FALSE;
   message_t pkt;
   uint8_t current_time_slot2=0;
  
   event void Boot.booted() {
        call AMControl.start();
    }


	// Main routine - triggers every time Timer0 ticks
	event void Timer0.fired() {
		current_time_slot2++;
	}

   event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			// start up our own routines
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
		}
		else {
			call AMControl.start();
		 }
	}
	
	event void AMControl.stopDone(error_t err) {
	}
   
	event void AMSend.sendDone(message_t* msg, error_t error){
		if (&pkt == msg) {
			busy = FALSE;	
		 }
	}
	
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		uint8_t id;
		BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
		id = btrpkt->nodeid;

		 //know its basestation send back an ack
		if (id == BASE_STATION_ID)
		{
			if(!busy){
			call Leds.led0Toggle();
			call Leds.led1Toggle();
			call Leds.led2Toggle();       
		        btrpkt = (call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->current_time_slot = current_time_slot2;
			
			 if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
                                        busy = TRUE;
		
				}
			}
		 }
		return msg;
	}	
}
