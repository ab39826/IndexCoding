	#ifndef BLINKTORADIOSENDER_H
	#define	BLINKTORADIOSENDER_H

   enum {
        AM_BLINKTORADIO = 6,
	TIMER_PERIOD_MILLI = 1000
       };
     
   typedef nx_struct BlinkToRadioMsg {
     nx_uint16_t nodeid;
     nx_uint16_t current_time_slot;
    } BlinkToRadioMsg;
   #endif
