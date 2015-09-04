#include "RxDecoder.h"

configuration RxDecoderAppC {}
implementation {
  components RxDecoderC as App, LedsC, MainC;
  components SerialActiveMessageC as AM;
  components new TimerMilliC();

  App.Boot -> MainC.Boot;
  App.Control -> AM;
  App.Receive -> AM.Receive[AM_DECODED_MSG];
  App.AMSend -> AM.AMSend[AM_DECODED_MSG];
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AM;
}


