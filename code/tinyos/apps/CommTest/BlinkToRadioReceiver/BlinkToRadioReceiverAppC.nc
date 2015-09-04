 #include <Timer.h>
 #include "BlinkToRadioReceiver.h"

 configuration BlinkToRadioReceiverAppC {
}
 implementation {
 components MainC;
 components LedsC;
 components BlinkToRadioReceiverC as App;
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

