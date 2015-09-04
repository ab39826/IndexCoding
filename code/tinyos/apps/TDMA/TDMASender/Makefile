COMPONENT=BlinkToRadioSenderAppC
BUILD_EXTRA_DEPS += SerialMsg.py # Serial.class SerialMsg.java
CLEAN_EXTRA = SerialMsg.py # *.pyc SerialMsg.java *.class

CFLAGS += -I$(TOSDIR)/lib/T2Hack

SerialMsg.py: BlinkToRadioSender.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=SerialMsg BlinkToRadioSender.h serial_msg -o $@

#Serial.class: $(wildcard *.java) SerialMsg.java
	#javac -target 1.4 -source 1.4 *.java

#SerialMsg.java:
	#mig java -target=null $(CFLAGS) -java-classname=SerialMsg BlinkToRadioSender.h serial_msg -o $@

include $(MAKERULES)
