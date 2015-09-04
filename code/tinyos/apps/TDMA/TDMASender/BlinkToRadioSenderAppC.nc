 #include <Timer.h>
 #include "BlinkToRadioSender.h"

 configuration BlinkToRadioSenderAppC {
}
 implementation {
 components MainC;
 components LedsC;
 components BlinkToRadioSenderC as App;
 components new TimerMilliC() as Timer0;

 components ActiveMessageC as Radio;
 components SerialActiveMessageC as Serial;

 components new AMSenderC(AM_BLINKTORADIO) as RadioSenderC;
 components new AMReceiverC(AM_BLINKTORADIO) as RadioReceiverC;
 
 components new SerialAMSenderC(AM_SERIAL_MSG) as SerialSenderC;
 //components new SerialAMReceiverC(AM_SERIAL_MSG) as SerialReceiverC;
	 
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.RadioPacket -> RadioSenderC;
  App.RadioAMPacket -> RadioSenderC;
  App.RadioSend -> RadioSenderC;
  App.RadioControl -> Radio;
  App.RadioReceive -> RadioReceiverC;

  App.UartSend -> SerialSenderC;
  App.UartSend -> Serial.AMSend[AM_SERIAL_MSG];
  //App.UartReceive -> SerialReceiverC;
  App.UartPacket -> Serial;
  App.UartAMPacket -> Serial;
  App.SerialControl -> Serial;
 }

