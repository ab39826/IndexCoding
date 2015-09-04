COMPONENT=TransmitterAppC
BUILD_EXTRA_DEPS += TxSerialMsg.py SymMsg.py AckMsg.py T2HMsg.py
CLEAN_EXTRA += TxSerialMsg.py SymMsg.py AckMsg.py T2HMsg.py *.pyc

CFLAGS += -I$(TOSDIR)/lib/T2Hack -DTOSH_DATA_LENGTH=96

TxSerialMsg.py: Transmitter.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=TxSerialMsg Transmitter.h tx_serial_msg -o $@

SymMsg.py: Transmitter.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=SymMsg Transmitter.h symbol_msg -o $@

AckMsg.py: Transmitter.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=AckMsg Transmitter.h ack_msg -o $@

T2HMsg.py: Transmitter.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=T2HMsg Transmitter.h target_to_host_msg -o $@

include $(MAKERULES)
#PFLAGS += linalg.c linalg.h decode_msgs.c decode_msgs.h
#PFLAGS += Transmitter.h
