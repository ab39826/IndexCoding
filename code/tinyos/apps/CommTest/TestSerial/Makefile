COMPONENT=TestSerialAppC
BUILD_EXTRA_DEPS += TestSerial.class TestSerialMsg.py
CLEAN_EXTRA = *.class TestSerialMsg.java MyMsg.py

CFLAGS += -I$(TOSDIR)/lib/T2Hack

TestSerialMsg.py: TestSerial.h
	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=TestSerialMsg TestSerial.h test_serial_msg -o $@

TestSerial.class: $(wildcard *.java) TestSerialMsg.java
	javac -target 1.4 -source 1.4 *.java

TestSerialMsg.java:
	mig java -target=null $(CFLAGS) -java-classname=TestSerialMsg TestSerial.h test_serial_msg -o $@


include $(MAKERULES)

