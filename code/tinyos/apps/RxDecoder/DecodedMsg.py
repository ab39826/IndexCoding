#
# This class is automatically generated by mig. DO NOT EDIT THIS FILE.
# This class implements a Python interface to the 'DecodedMsg'
# message type.
#

import tinyos.message.Message

# The default size of this message type in bytes.
DEFAULT_MESSAGE_SIZE = 34

# The Active Message type associated with this message.
AM_TYPE = 137

class DecodedMsg(tinyos.message.Message.Message):
    # Create a new DecodedMsg of size 34.
    def __init__(self, data="", addr=None, gid=None, base_offset=0, data_length=34):
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
        s = "Message <DecodedMsg> \n"
        try:
            s += "  [counter=0x%x]\n" % (self.get_counter())
        except:
            pass
        try:
            s += "  [current_row=0x%x]\n" % (self.get_current_row())
        except:
            pass
        try:
            s += "  [V_row=";
            for i in range(0, 8):
                s += "%f " % (self.getElement_V_row(i))
            s += "]\n";
        except:
            pass
        return s

    # Message-type-specific access methods appear below.

    #
    # Accessor methods for field: counter
    #   Field type: short
    #   Offset (bits): 0
    #   Size (bits): 8
    #

    #
    # Return whether the field 'counter' is signed (True).
    #
    def isSigned_counter(self):
        return True
    
    #
    # Return whether the field 'counter' is an array (False).
    #
    def isArray_counter(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'counter'
    #
    def offset_counter(self):
        return (0 / 8)
    
    #
    # Return the offset (in bits) of the field 'counter'
    #
    def offsetBits_counter(self):
        return 0
    
    #
    # Return the value (as a short) of the field 'counter'
    #
    def get_counter(self):
        return self.getUIntElement(self.offsetBits_counter(), 8, 1)
    
    #
    # Set the value of the field 'counter'
    #
    def set_counter(self, value):
        self.setUIntElement(self.offsetBits_counter(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'counter'
    #
    def size_counter(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'counter'
    #
    def sizeBits_counter(self):
        return 8
    
    #
    # Accessor methods for field: current_row
    #   Field type: short
    #   Offset (bits): 8
    #   Size (bits): 8
    #

    #
    # Return whether the field 'current_row' is signed (True).
    #
    def isSigned_current_row(self):
        return True
    
    #
    # Return whether the field 'current_row' is an array (False).
    #
    def isArray_current_row(self):
        return False
    
    #
    # Return the offset (in bytes) of the field 'current_row'
    #
    def offset_current_row(self):
        return (8 / 8)
    
    #
    # Return the offset (in bits) of the field 'current_row'
    #
    def offsetBits_current_row(self):
        return 8
    
    #
    # Return the value (as a short) of the field 'current_row'
    #
    def get_current_row(self):
        return self.getUIntElement(self.offsetBits_current_row(), 8, 1)
    
    #
    # Set the value of the field 'current_row'
    #
    def set_current_row(self, value):
        self.setUIntElement(self.offsetBits_current_row(), 8, value, 1)
    
    #
    # Return the size, in bytes, of the field 'current_row'
    #
    def size_current_row(self):
        return (8 / 8)
    
    #
    # Return the size, in bits, of the field 'current_row'
    #
    def sizeBits_current_row(self):
        return 8
    
    #
    # Accessor methods for field: V_row
    #   Field type: float[]
    #   Offset (bits): 16
    #   Size of each element (bits): 32
    #

    #
    # Return whether the field 'V_row' is signed (True).
    #
    def isSigned_V_row(self):
        return True
    
    #
    # Return whether the field 'V_row' is an array (True).
    #
    def isArray_V_row(self):
        return True
    
    #
    # Return the offset (in bytes) of the field 'V_row'
    #
    def offset_V_row(self, index1):
        offset = 16
        if index1 < 0 or index1 >= 8:
            raise IndexError
        offset += 0 + index1 * 32
        return (offset / 8)
    
    #
    # Return the offset (in bits) of the field 'V_row'
    #
    def offsetBits_V_row(self, index1):
        offset = 16
        if index1 < 0 or index1 >= 8:
            raise IndexError
        offset += 0 + index1 * 32
        return offset
    
    #
    # Return the entire array 'V_row' as a float[]
    #
    def get_V_row(self):
        tmp = [None]*8
        for index0 in range (0, self.numElements_V_row(0)):
                tmp[index0] = self.getElement_V_row(index0)
        return tmp
    
    #
    # Set the contents of the array 'V_row' from the given float[]
    #
    def set_V_row(self, value):
        for index0 in range(0, len(value)):
            self.setElement_V_row(index0, value[index0])

    #
    # Return an element (as a float) of the array 'V_row'
    #
    def getElement_V_row(self, index1):
        return self.getFloatElement(self.offsetBits_V_row(index1), 32, 0)
    
    #
    # Set an element of the array 'V_row'
    #
    def setElement_V_row(self, index1, value):
        self.setFloatElement(self.offsetBits_V_row(index1), 32, value, 0)
    
    #
    # Return the total size, in bytes, of the array 'V_row'
    #
    def totalSize_V_row(self):
        return (256 / 8)
    
    #
    # Return the total size, in bits, of the array 'V_row'
    #
    def totalSizeBits_V_row(self):
        return 256
    
    #
    # Return the size, in bytes, of each element of the array 'V_row'
    #
    def elementSize_V_row(self):
        return (32 / 8)
    
    #
    # Return the size, in bits, of each element of the array 'V_row'
    #
    def elementSizeBits_V_row(self):
        return 32
    
    #
    # Return the number of dimensions in the array 'V_row'
    #
    def numDimensions_V_row(self):
        return 1
    
    #
    # Return the number of elements in the array 'V_row'
    #
    def numElements_V_row():
        return 8
    
    #
    # Return the number of elements in the array 'V_row'
    # for the given dimension.
    #
    def numElements_V_row(self, dimension):
        array_dims = [ 8,  ]
        if dimension < 0 or dimension >= 1:
            raise IndexException
        if array_dims[dimension] == 0:
            raise IndexError
        return array_dims[dimension]
    