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

 components new AMSenderC(AM_SYMBOL_MSG) as RadioSenderC;
 components new AMReceiverC(AM_SYMBOL_MSG) as RadioReceiverC;
 
 //components new SerialAMSenderC(AM_SERIAL_MSG) as SerialSenderC;
 //components new SerialAMReceiverC(AM_SERIAL_MSG) as SerialReceiverC;
	 
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.RadioPacket -> RadioSenderC;
  App.RadioAMPacket -> RadioSenderC;
  App.RadioSend -> RadioSenderC;
  App.RadioControl -> Radio;
  App.RadioReceive -> RadioReceiverC;

  //App.UartSend -> SerialSenderC;
  App.UartSend -> Serial.AMSend[AM_TX_SERIAL_MSG];
  //App.UartReceive -> SerialReceiverC;
  App.UartPacket -> Serial;
  App.UartAMPacket -> Serial;
  App.SerialControl -> Serial;
 }

