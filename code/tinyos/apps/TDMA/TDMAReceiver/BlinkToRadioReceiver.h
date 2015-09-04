	#ifndef BLINKTORADIORECEIVER_H
	#define	BLINKTORADIORECEIVER_H

#define BASE_STATION_ID 100
   enum {
        AM_BLINKTORADIO = 6,
	TIMER_PERIOD_MILLI = 1000
       };
     
   typedef nx_struct BlinkToRadioMsg {
     nx_uint16_t nodeid;
     nx_uint16_t messageid;
    } BlinkToRadioMsg;

   #endif
