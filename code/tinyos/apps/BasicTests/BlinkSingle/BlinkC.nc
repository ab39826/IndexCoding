/**
 * Implementation for Blink application.  Toggle the red LED when a
 * Timer fires.
**/

#include "Timer.h"

module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Leds;
  uses interface Boot;
}
implementation
{

	uint8_t counter = 0;

	event void Boot.booted()
	{
		call Timer0.startPeriodic( 250 );
	}

  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
	 counter++;
	 call Leds.set(counter);
  }
  
}

