#include "RxDecoder.h"

configuration RxDecoderAppC {}
implementation {
  components MainC;
  components LedsC;
  components RxDecoderC as App;
  components ActiveMessageC as Radio;
  components new TimerMilliC();
  //components new AMSenderC(AM_ACK_MSG) as RadioSenderC;
  components new AMReceiverC(AM_SYMBOL_MSG) as RadioReceiverC; //receiver to transmitter
  components new AMSenderC(AM_SYMBOL_MSG) as RadioSenderC; //just try this...
  //components new AMSenderC(AM_ACK_MSG) as RadioSenderC; 
  //components new AMReceiverC(AM_ACK_MSG) as RadioReceiverC; //FOR RECEVIER TO RECEIVER TEST
	//CHANGE TO RECEIVE ON BROADCAST AND SEND TO TRANSMITTER?




  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  //App.Timer0 -> Timer0;
  App.RadioPacket -> RadioSenderC; //originall -> AM
  App.RadioAMPacket -> RadioSenderC;//
  App.RadioSend -> RadioSenderC;// see how this is working in the transmitter code. Like where "AM_DECODED_MSG" transmitter equivalent is being used. Mainly to make sure that can't have both  AMSend and AMReceive both have the same parameter. originally AM.AMSend[ AM_DECODED_MSG]
  App.RadioControl -> Radio;
  App.RadioReceive -> RadioReceiverC; //originally AM.Receive[AM_DECODED_MSG]
  App.MilliTimer -> TimerMilliC;

}


//next, need to emulate how TDMAReceiver is receivng radio messages. Should be easy enough.

