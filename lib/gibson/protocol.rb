# Copyright (c) 2013, Simone Margaritelli <evilsocket at gmail dot com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of Gibson nor the names of its contributors may be used
#     to endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
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
        ERRORS = {
            0 => GenericError,
            1 => NotFoundError,
            2 => NaNError,
            3 => OutOfMemoryError,
            4 => LockedError
        }

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
