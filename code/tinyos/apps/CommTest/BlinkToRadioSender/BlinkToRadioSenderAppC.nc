 #include <Timer.h>
 #include "BlinkToRadioSender.h"

 configuration BlinkToRadioSenderAppC {
}
 implementation {
 components MainC;
 components LedsC;
 components BlinkToRadioSenderC as App;
 components new TimerMilliC() as Timer0;
 components ActiveMessageC;
 components new AMSenderC(AM_BLINKTORADIO);
 components new AMReceiverC(AM_BLINKTORADIO);
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Receive -> AMReceiverC;
 }

