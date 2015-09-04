
#ifndef RX_DECODER_H
#define RX_DECODER_H

#include "linalg.h"
#include "decode_msgs.h"
//have to define N in linalg.c as well
#define N 8
#define I 6
#define PIECES 8
#define PIECESIZE 16
#define A  (N-I-1)

float** Make2DFloatArray(int arraySizeX, int arraySizeY);

//making changes to try and send current_row, naming shouldnt matter
typedef nx_struct symbol_msg {// message receiver gets from transmitter
  nx_float V_coeff[N];
  //nx_uint16_t data[PIECES];
  nx_float data[PIECES];
  nx_uint16_t crow;
  nx_uint16_t messageid;
  nx_uint16_t current_transmission;

  /*} decoded_msg_t;*/
} symbol_msg_t;
 // if crow is negative, store transmit initial setup row (-1 want, 0 anditode, 1 interference) in V_coeff?

typedef nx_struct ack_msg{// message receiver sends to transmitter
	nx_uint16_t nodeid;
	nx_uint16_t ack_type;
	nx_uint16_t current_transmission;
	
} ack_msg_t;


enum {
 // AM_DECODED_MSG = 0x89,
  TIMER_PERIOD = 500,
  AM_SYMBOL_MSG = 6,
  AM_ACK_MSG = 7
};

#endif
