
#ifndef RX_DECODER_H
#define RX_DECODER_H

#include "linalg.h"
#include "decode_msgs.h"
//have to define N in linalg.c as well
#define N 8
#define I 4
#define PIECES 1
#define PIECESIZE 16
#define A  (N-I-1)

float** Make2DFloatArray(int arraySizeX, int arraySizeY);

//making changes to try and send current_row
typedef nx_struct decoded_msg {
  nx_float V_coeff[N];
  nx_uint16_t data[PIECES];
  nx_uint16_t crow;
} decoded_msg_t;

enum {
  AM_DECODED_MSG = 0x89,
  TIMER_PERIOD = 500,
};

#endif
