COMPONENT=BlinkToRadioAppC
BUILD_EXTRA_DEPS += BlinkToRadioMsg.class
CLEAN_EXTRA = *.class BlinkToRadioMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack -DTOSH_DATA_LENGTH=112

BlinkToRadioMsg.class: $(wildcard *.java) BlinkToRadioMsg.java
	javac -target 1.6 -source 1.6 *.java

BlinkToRadioMsg.java:
	mig java -target=micaz $(CFLAGS) -java-classname=BlinkToRadioMsg BlinkToRadio.h BlinkToRadioMsg -o $@

include $(MAKERULES)
