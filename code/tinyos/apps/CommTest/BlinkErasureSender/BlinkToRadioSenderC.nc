 #include <Timer.h>
 #include "BlinkToRadioSender.h"

 module BlinkToRadioSenderC {
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
   current_time_slot = 0;
   uint8_t num_acks[2] = {0x00, 0x00 };
   uint8_t ack_r1 = 0;
   uint8_t ack_r2 = 0;
     
   event void Boot.booted() {
        call AMControl.start();
    }


	// Main routine - triggers every time Timer0 ticks
	event void Timer0.fired() {
		current_time_slot++;

		if ( current_time_slot%2 ==0) {
			call Leds.led0Toggle();
			   }

		if ( current_time_slot%2 !=0) {
			//do nothing for now
			   }
			
		
		if (!busy) {
			if(current_time_slot%2==0)
			      {
				BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*) (call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
				btrpkt->nodeid = TOS_NODE_ID;
				btrpkt->current_time_slot = current_time_slot;
				if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
					busy = TRUE;
                                      }
				         }
		}
	}

   event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
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


		if(id == 0) {
			ack_r1 = num_acks[id];
			ack_r1++;
			num_acks[id]= ack_r1;
			call Leds.led2Toggle();
			}


		if(id == 1) {
			ack_r2 = num_acks[id];
			ack_r2++;
			num_acks[id] = ack_r2;
			call Leds.led1Toggle();
			}

			
		
	return msg;
	}	
}
