
#ifndef RX_DECODER_H
#define RX_DECODER_H

#include "linalg.h"
#include "decode_msgs.h"

#define N 8
#define I 4

float** Make2DFloatArray(int arraySizeX, int arraySizeY);

typedef nx_struct decoded_msg {
  nx_uint8_t counter;
  nx_uint8_t current_row;
  nx_float V_row[N];
} decoded_msg_t;

enum {
  AM_DECODED_MSG = 0x89,
  TIMER_PERIOD = 500,
};

#endif
