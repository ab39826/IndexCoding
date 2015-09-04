 #include <Timer.h>
 #include "BlinkToRadioSender.h"

 module BlinkToRadioSenderC {
uses{
  interface Boot;
  interface SplitControl as RadioControl;
  interface SplitControl as SerialControl;
  interface Leds;
  interface Timer<TMilli> as Timer0; 
 
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
   bool busy = FALSE;
	bool locked = FALSE;
   message_t radiopkt;
	message_t serialpkt;
   uint8_t acks[NUM_NODES] = {0};
	uint8_t index =0;
   uint32_t transmissions = 0;
   uint32_t rounds =0;
   uint8_t currentmessage = 0; //default to having receiver 0 getting first message  
   event void Boot.booted() {
      call SerialControl.start();  
		  
    }


	// Main routine - triggers every time Timer0 ticks
	event void Timer0.fired() {
		
			
		
		if (!busy){
				      
				BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*) (call RadioPacket.getPayload(&radiopkt, sizeof (BlinkToRadioMsg)));
				btrpkt->nodeid = TOS_NODE_ID;
			  

				while(acks[currentmessage]==1){
					currentmessage++;
					if(currentmessage == NUM_NODES){
						currentmessage = 0;
					}
				}
				btrpkt->messageid = currentmessage;
			  //prepare for next message.
				
				if (call RadioSend.send(AM_BROADCAST_ADDR, &radiopkt, sizeof(BlinkToRadioMsg)) == SUCCESS){
					busy = TRUE;
					transmissions++;
					currentmessage++;
					if(currentmessage == NUM_NODES){
						currentmessage = 0;
						}

             }
				         
		}



	}

   event void RadioControl.startDone(error_t err) {
			
		if (err == SUCCESS) {
			call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
			
			//initializing acks array 
			for(index =0; index<NUM_NODES; index++){
				acks[index]=0;
			}
				
		}
		else {
			call RadioControl.start();
		}


	}

	event void SerialControl.startDone(error_t err){
		if( err != SUCCESS) {
			call SerialControl.start();
		}
		call RadioControl.start();
	}
	
	event void RadioControl.stopDone(error_t err) {
	}

	event void SerialControl.stopDone(error_t err) {
	}
   
	event void RadioSend.sendDone(message_t* msg, error_t error){
		if (&radiopkt == msg) {
			busy = FALSE;	
		 }
	}

	event void UartSend.sendDone(message_t* bufPtr, error_t error){
		if (&serialpkt == bufPtr){
			locked = FALSE;
		}
	}
	
	event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len) {
	
      uint8_t id;
		uint8_t i;
		uint8_t totalacks = 0;
		

		BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload; //unpacks the message
		id = btrpkt->nodeid;
		


		if(acks[id]!=1){
		acks[id]=1;
		}

		//checking to see whether all 
		for(i=0; i<NUM_NODES; i++){
		
		if(acks[i] == 1){
		   totalacks++;
		   }
		}
		

                //Means that all Receivers have received message. increment rounds and reset acknoledgement array
		if(totalacks == NUM_NODES){
				rounds++;
				call Leds.led0Toggle(); //heartbeat
				
				for(i=0; i<NUM_NODES; i++){
					acks[i]=0;


					}
				//do something with sending it to the serial port at this point
			if (locked){return msg;}

			else{
				serial_msg_t* rcm = (serial_msg_t*) call UartPacket.getPayload(&serialpkt, sizeof(serial_msg_t));
				call Leds.led1Toggle();
				rcm->num_nodes = NUM_NODES;
				rcm->num_rounds = rounds;
				rcm->num_transmissions = transmissions;
				if( rcm == NULL) {
					return msg;
				}
				if (call UartPacket.maxPayloadLength() < sizeof (serial_msg_t)) {
					return msg;
				}

				if(call UartSend.send(AM_BROADCAST_ADDR, &serialpkt, sizeof(serial_msg_t)) == SUCCESS) {
					call Leds.led2Toggle();
					locked = TRUE;
					transmissions = 0;
				}
			 }
		}
		

	return msg;
	}

	//event message_t* SerialReceive.receive(message_t* msg, void * payload, uint8_t len){
		/*
		uint8_t nodenum;
		uint32_t rounds;
		uint32_t trans;

		if( len != sizeof(serial_msg_t)) {return msg;}
		else{
			serial_msg_t* rcm = (serial_msg_t*)payload;

			nodenum = rcm->num_nodes;
			rounds = rcm->num_rounds;
			trans = rcm->num_transmissions;

		}
		*/

	//}	
}
