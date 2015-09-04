#ifndef BLINKTORADIOSENDER_H
#define	BLINKTORADIOSENDER_H
#define NUM_NODES 5
enum {
	AM_BLINKTORADIO = 6,
	AM_SERIAL_MSG = 7,
	TIMER_PERIOD_MILLI = 100
};
     

typedef nx_struct serial_msg {
	nx_uint8_t num_nodes;
	nx_uint32_t num_rounds;
	nx_uint32_t num_transmissions;
} serial_msg_t;

typedef nx_struct BlinkToRadioMsg {
	nx_uint16_t nodeid;
	nx_uint16_t messageid;
} BlinkToRadioMsg;

#endif
