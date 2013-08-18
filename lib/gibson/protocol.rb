module Gibson
  # A generic protocol error.
  class GenericError < RuntimeError; end
  # Key or prefix not found.
  class NotFoundError < RuntimeError; end
  # Specified value is not a number.
  class NaNError < RuntimeError; end
  # The server is out of memory.
  class OutOfMemoryError < RuntimeError; end
  # The object is locked and can't be modified.
  class LockedError < RuntimeError; end

  class Protocol
    # Query opcodes.
    COMMANDS = {
      :set     => 1,
      :ttl     => 2,
      :get     => 3,
      :del     => 4,
      :inc     => 5,
      :dec     => 6,
      :lock    => 7,  
      :unlock  => 8,  
      :mset    => 9,  
      :mttl    => 10, 
      :mget    => 11, 
      :mdel    => 12, 
      :minc    => 13, 
      :mdec    => 14, 
      :mlock   => 15, 
      :munlock => 16, 
      :count   => 17, 
      :stats   => 18, 
      :ping    => 19, 
      :meta    => 20, 
      :keys    => 21, 
      :end     => 0xff
    }

    # Server replies opcodes.
    REPLIES = {
      :error 	   => 0, # Generic error
      :not_found => 1, # Key/Prefix not found
      :nan 	   => 2, # Not a number
      :mem	   => 3, # Out of memory
      :locked    => 4, # Object is locked
      :ok  	   => 5, # Ok, no data follows
      :val 	   => 6, # Ok, scalar value follows
      :kval	   => 7  # Ok, [ key => value, ... ] follows
    }

    # Error code to exception map.
    ERRORS = [
      GenericError,
      NotFoundError,
      NaNError,
      OutOfMemoryError,
      LockedError
    ]

    # Incoming data encodings.
    ENCODINGS = {
      # the item is in plain encoding and data points to its buffer
      :plain  => 0x00, 
      # PLAIN but compressed data with lzf
      :lzf    => 0x01, 
      # the item contains a number and data pointer is actually that number
      :number => 0x02 
    }

    ##
    # Return true if the specified code is an error code, otherwise false.
    def self.error? (code)
      code >= REPLIES[:error] && code <= REPLIES[:locked]
    end
  end
end
