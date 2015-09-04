// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

#define MSGSIZE 111
enum {
  AM_BLINKTORADIOMSG = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint8_t nodeid;
  /*nx_uint16_t counter;*/
  nx_uint8_t msg_array[MSGSIZE];
} BlinkToRadioMsg;

#endif
