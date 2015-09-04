#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'SerialMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 9

# The Active Message type associated with this message.
AM_TYPE = 7

class SerialMsg(tinyos.message.Message.Message):
    # Create a new SerialMsg of size 9.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=9):
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
        s = "Message <SerialMsg> \n"
        try:
            s += "  [num_nodes=0x%x]\n" % (self.get_num_nodes())
        except:
            pass
        try:
            s += "  [num_rounds=0x%x]\n" % (self.get_num_rounds())
        except:
            pass
        try:
            s += "  [num_transmissions=0x%x]\n" % (self.get_num_transmissions())
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: num_nodes
    #   Field type: short
    #   Offset (bits): 0
    #   Size (bits): 8
    #

    #
    # Return whether the field 'num_nodes' is signed (False).
    #
    def isSigned_num_nodes(self):
        return False
    
    #
    # Return whether the field 'num_nodes' is an array (False).
    #
    def isArray_num_nodes(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'num_nodes'
    #
    def offset_num_nodes(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'num_nodes'
    #
    def offsetBits_num_nodes(self):
        return 0
    
    #
    # Return the value (as a short) of the field 'num_nodes'
    #
    def get_num_nodes(self):
        return self.getUIntElement(self.offsetBits_num_nodes(), 8, 1)
    
    #
    # Set the value of the field 'num_nodes'
    #
    def set_num_nodes(self, value):
        self.setUIntElement(self.offsetBits_num_nodes(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'num_nodes'
    #
    def size_num_nodes(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'num_nodes'
    #
    def sizeBits_num_nodes(self):
        return 8
    
    #
    # Accessor methods for field: num_rounds
    #   Field type: long
    #   Offset (bits): 8
    #   Size (bits): 32
    #

    #
    # Return whether the field 'num_rounds' is signed (False).
    #
    def isSigned_num_rounds(self):
        return False
    
    #
    # Return whether the field 'num_rounds' is an array (False).
    #
    def isArray_num_rounds(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'num_rounds'
    #
    def offset_num_rounds(self):
        return (8 / 8)
    
    #
    # Return the offset (in bits) of the field 'num_rounds'
    #
    def offsetBits_num_rounds(self):
        return 8
    
    #
    # Return the value (as a long) of the field 'num_rounds'
    #
    def get_num_rounds(self):
        return self.getUIntElement(self.offsetBits_num_rounds(), 32, 1)
    
    #
    # Set the value of the field 'num_rounds'
    #
    def set_num_rounds(self, value):
        self.setUIntElement(self.offsetBits_num_rounds(), 32, value, 1)
    
    #
    # Return the size, in bytes, of the field 'num_rounds'
    #
    def size_num_rounds(self):
        return (32 / 8)
    
    #
    # Return the size, in bits, of the field 'num_rounds'
    #
    def sizeBits_num_rounds(self):
        return 32
    
    #
    # Accessor methods for field: num_transmissions
    #   Field type: long
    #   Offset (bits): 40
    #   Size (bits): 32
    #

    #
    # Return whether the field 'num_transmissions' is signed (False).
    #
    def isSigned_num_transmissions(self):
        return False
    
    #
    # Return whether the field 'num_transmissions' is an array (False).
    #
    def isArray_num_transmissions(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'num_transmissions'
    #
    def offset_num_transmissions(self):
        return (40 / 8)
    
    #
    # Return the offset (in bits) of the field 'num_transmissions'
    #
    def offsetBits_num_transmissions(self):
        return 40
    
    #
    # Return the value (as a long) of the field 'num_transmissions'
    #
    def get_num_transmissions(self):
        return self.getUIntElement(self.offsetBits_num_transmissions(), 32, 1)
    
    #
    # Set the value of the field 'num_transmissions'
    #
    def set_num_transmissions(self, value):
        self.setUIntElement(self.offsetBits_num_transmissions(), 32, value, 1)
    
    #
    # Return the size, in bytes, of the field 'num_transmissions'
    #
    def size_num_transmissions(self):
        return (32 / 8)
    
    #
    # Return the size, in bits, of the field 'num_transmissions'
    #
    def sizeBits_num_transmissions(self):
        return 32
    
