
#ifndef RX_DECODER_H
#define RX_DECODER_H

#include "svd.h"

#define N 15
#define L 100

#define TRUE 1
#define FALSE 0

int null_vec(float **X, int l, int n, float *z, float tol);
float** Make2DFloatArray(int arraySizeX, int arraySizeY);

typedef nx_struct decoded_msg {
  nx_uint8_t counter;
  nx_uint8_t perform_svd;
  nx_float A[N];
} decoded_msg_t;

enum {
  AM_DECODED_MSG = 0x89,
  TIMER_PERIOD = 100,
};

#endif
