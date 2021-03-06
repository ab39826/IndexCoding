#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'AckMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 6

# The Active Message type associated with this message.
AM_TYPE = 100

class AckMsg(tinyos.message.Message.Message):
    # Create a new AckMsg of size 6.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=6):
        tinyos.message.Message.Message.__init__(self, data, addr, gid, base_offset, data_length)
        self.amTypeSet(AM_TYPE)
    
    # Get AM_TYPE
    def get_amType(cls):
        return AM_TYPE
    
    get_amType = classmethod(get_amType)
    
    #
    # Return a String representation of this message. Includes the
    # message type name and the non-indexed field values.
    #
    def __str__(self):
        s = "Message <AckMsg> \n"
        try:
            s += "  [nodeid=0x%x]\n" % (self.get_nodeid())
        except:
            pass
        try:
            s += "  [ack_type=0x%x]\n" % (self.get_ack_type())
        except:
            pass
        try:
            s += "  [current_transmission=0x%x]\n" % (self.get_current_transmission())
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: nodeid
    #   Field type: int
    #   Offset (bits): 0
    #   Size (bits): 16
    #

    #
    # Return whether the field 'nodeid' is signed (False).
    #
    def isSigned_nodeid(self):
        return False
    
    #
    # Return whether the field 'nodeid' is an array (False).
    #
    def isArray_nodeid(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'nodeid'
    #
    def offset_nodeid(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'nodeid'
    #
    def offsetBits_nodeid(self):
        return 0
    
    #
    # Return the value (as a int) of the field 'nodeid'
    #
    def get_nodeid(self):
        return self.getUIntElement(self.offsetBits_nodeid(), 16, 1)
    
    #
    # Set the value of the field 'nodeid'
    #
    def set_nodeid(self, value):
        self.setUIntElement(self.offsetBits_nodeid(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'nodeid'
    #
    def size_nodeid(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'nodeid'
    #
    def sizeBits_nodeid(self):
        return 16
    
    #
    # Accessor methods for field: ack_type
    #   Field type: int
    #   Offset (bits): 16
    #   Size (bits): 16
    #

    #
    # Return whether the field 'ack_type' is signed (False).
    #
    def isSigned_ack_type(self):
        return False
    
    #
    # Return whether the field 'ack_type' is an array (False).
    #
    def isArray_ack_type(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'ack_type'
    #
    def offset_ack_type(self):
        return (16 / 8)
    
    #
    # Return the offset (in bits) of the field 'ack_type'
    #
    def offsetBits_ack_type(self):
        return 16
    
    #
    # Return the value (as a int) of the field 'ack_type'
    #
    def get_ack_type(self):
        return self.getUIntElement(self.offsetBits_ack_type(), 16, 1)
    
    #
    # Set the value of the field 'ack_type'
    #
    def set_ack_type(self, value):
        self.setUIntElement(self.offsetBits_ack_type(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'ack_type'
    #
    def size_ack_type(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'ack_type'
    #
    def sizeBits_ack_type(self):
        return 16
    
    #
    # Accessor methods for field: current_transmission
    #   Field type: int
    #   Offset (bits): 32
    #   Size (bits): 16
    #

    #
    # Return whether the field 'current_transmission' is signed (False).
    #
    def isSigned_current_transmission(self):
        return False
    
    #
    # Return whether the field 'current_transmission' is an array (False).
    #
    def isArray_current_transmission(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'current_transmission'
    #
    def offset_current_transmission(self):
        return (32 / 8)
    
    #
    # Return the offset (in bits) of the field 'current_transmission'
    #
    def offsetBits_current_transmission(self):
        return 32
    
    #
    # Return the value (as a int) of the field 'current_transmission'
    #
    def get_current_transmission(self):
        return self.getUIntElement(self.offsetBits_current_transmission(), 16, 1)
    
    #
    # Set the value of the field 'current_transmission'
    #
    def set_current_transmission(self, value):
        self.setUIntElement(self.offsetBits_current_transmission(), 16, value, 1)
    
    #
    # Return the size, in bytes, of the field 'current_transmission'
    #
    def size_current_transmission(self):
        return (16 / 8)
    
    #
    # Return the size, in bits, of the field 'current_transmission'
    #
    def sizeBits_current_transmission(self):
        return 16
    
