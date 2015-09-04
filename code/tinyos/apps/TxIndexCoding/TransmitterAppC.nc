 #include <Timer.h>
 #include "Transmitter.h"

 configuration TransmitterAppC {
}
 implementation {
 components MainC;
 components LedsC;
 components TransmitterC as App;
 components new TimerMilliC() as Timer0;

 components ActiveMessageC as Radio;
 components SerialActiveMessageC as Serial;

 //components new AMSenderC(AM_SYMBOL_MSG) as RadioSenderC;
 ////components new AMReceiverC(AM_ACK_MSG) as RadioReceiverC;
 //components new AMReceiverC(AM_SYMBOL_MSG) as RadioReceiverC; //just try this
 
 //components new SerialAMSenderC(AM_TARGET_TO_HOST_MSG) as SerialSenderC; //should work but it doesnt
 components new SerialAMSenderC(AM_TX_SERIAL_MSG) as SerialSenderC; //why does this work?
 components new SerialAMReceiverC(AM_TX_SERIAL_MSG) as SerialReceiverC;
//CHANGE TO SEND ON BROADCAST AND RECEIVE ON TRANSMITTER
 components new AMSenderC(AM_SYMBOL_MSG) as RadioSenderC; //whats in () doesnt actually matter?
 components new AMReceiverC(AM_ACK_MSG) as RadioReceiverC; //receive acks addressed to itself

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.RadioPacket -> RadioSenderC;
  App.RadioAMPacket -> RadioSenderC;
  App.RadioSend -> RadioSenderC;
  App.RadioControl -> Radio;
  App.RadioReceive -> RadioReceiverC;
  
  App.UartSend -> SerialSenderC; //should work but it doesnt when set to AM_TARGET_TO_HOST_MSG
  //App.UartSend -> Serial.AMSend[AM_TX_SERIAL_MSG]; //why does this work?
  //App.UartSend -> Serial.AMSend[AM_TARGET_TO_HOST_MSG]; //maybe this should work, but it doesnt
  App.UartReceive -> SerialReceiverC;
  App.UartPacket -> Serial;
  App.UartAMPacket -> Serial;
  App.SerialControl -> Serial;
 }

