COMPONENT=RxDecoderAppC
BUILD_EXTRA_DEPS += DecodedMsg.py
CLEAN_EXTRA = DecodedMsg.py *.pyc

CFLAGS += -I$(TOSDIR)/lib/T2Hack -DTOSH_DATA_LENGTH=96

DecodedMsg.py: RxDecoder.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=DecodedMsg RxDecoder.h decoded_msg -o $@

include $(MAKERULES)
PFLAGS += svd.c svd.h
