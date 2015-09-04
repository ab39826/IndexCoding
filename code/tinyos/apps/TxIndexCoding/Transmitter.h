#ifndef TRANSMITTER_H
#define TRANSMITTER_H

#define N 8
#define PIECES 4

enum {
	AM_TX_SERIAL_MSG = 5,
	AM_SYMBOL_MSG = 6,
	/*AM_ACK_MSG = 7,*/
	AM_ACK_MSG = 100,
	//ADDING SERIAL MSG?? AM_T2H_MSG??
	AM_TARGET_TO_HOST_MSG = 8,
	TIMER_PERIOD_MILLI = 1000
};
     
typedef nx_struct tx_serial_msg {
	/*nx_uint8_t num_nodes;
	nx_uint32_t num_rounds;
	nx_uint32_t num_transmissions*/
	/*nx_float J_k[N]; // send to host a single J_row over N transmissions*/
	/*nx_float V_row[N]; // receive from host a single row over m transmissions*/
	/*nx_uint8_t current_row;
	nx_float V_coeff[N];
	nx_uint16_t data[PIECES];*/
	//NEW: send float coeff int16 data[PIECES] int8 current_row int8 messageid (101, 102,... or 255)
	/*nx_uint8_t dest[N]; //where to send message to, either which remain or which get antidote W[i], ABSTRACT AWAY DEST AND CROW INSTEAD?*/
	nx_float V_row[N];
	//nx_uint16_t crow;
	nx_float data[PIECES];
	/*nx_uint8_t messageid;*/
	nx_uint16_t messageid;
	nx_uint16_t current_transmission;
	//	add round also?
} tx_serial_msg_t;

typedef nx_struct target_to_host_msg {
	nx_uint16_t ACKs[N];
	/*nx_uint16_t round;*/
	nx_uint16_t transmission;
} target_to_host_msg_t;
//} AM_T2H_MSG;

typedef nx_struct symbol_msg {  //add messageid flag to determine if TDMA or broadcast mode, also need current row to decode and current_tramsissionn to sync
	nx_float V_coeff[N];
	nx_float data[PIECES];
	//nx_uint16_t crow;
	/*nx_uint8_t messageid;*/
	nx_uint16_t messageid;
	nx_uint16_t current_transmission;
	//add round also?
} symbol_msg_t;

typedef nx_struct ack_msg {
	nx_uint16_t nodeid;
	nx_uint16_t ack_type;
	nx_uint16_t current_transmission;
} ack_msg_t;

#endif
