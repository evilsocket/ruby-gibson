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
require 'gibson/protocol'
require 'gibson/connection'

module Gibson
    class Client
        ##
        # Create a new Gibson::Client instance, the options are passed to
        # Gibson::Connection initialize method.
        def initialize(opts = {})
            @connection = nil
            @options = opts
        end

        ##
        # Create the connection.
        def connect
            @connection = Connection.new( @options )
            @connection.connect
        end

        ##
        # Decode a REPL_VAL reply.
        def decode_val( encoding, size, data )
            # plain string
            if encoding == Protocol::ENCODINGS[:plain]
                data.unpack( 'Z' + size.to_s )[0]
            # number
            elsif encoding == Protocol::ENCODINGS[:number]
                # 32 bit integer ?
                if size == 4
                    data.unpack( 'l<' )[0]
                else
                    data.unpack( 'q<' )[0]
                end
            else
                raise 'Unknown data encoding.'
            end
        end

        ##
        # Decode a REPL_KVAL reply.
        def decode_kval( data, size )
            left = size - 4
            count, data  = data.unpack( 'L<a' + left.to_s )
            obj = {}

            count.times do |i|
                left -= 4
                klen, data = data.unpack( 'L<a' + left.to_s )

                left -= klen
                key, data = data.unpack( 'a' + klen.to_s + 'a' + left.to_s )
                
                left -= 1
                enc, data = data.unpack( 'ca' + left.to_s )

                left -= 4
                vsize, data = data.unpack( 'L<a' + left.to_s )

                left -= vsize
                value, data = data.unpack( 'a' + vsize.to_s + 'a' + left.to_s )

                obj[key] = decode Protocol::REPLIES[:val], enc, vsize, value
            end

            obj
        end

        ##
        # Reply decoding wrapper.
        def decode( code, encoding, size, data )
            if code == Protocol::REPLIES[:val]
                decode_val encoding, size, data

            elsif code == Protocol::REPLIES[:kval]
                decode_kval data, size

            elsif code == Protocol::REPLIES[:ok]
                true

            elsif Protocol.error? code
                raise Protocol::ERRORS[code]

            else
                data
            end
        end

        ##
        # Send a query to the server given its opcode and arguments payload.
        # Return the decoded data, or raise one of the RuntimeErrors defined 
        # inside Gibson::Protocol.
        def query( opcode, payload = '' )
            connect if @connection == nil or not @connection.connected?

            psize  = payload.length
            packet = [ 2 + psize, opcode, payload ].pack( 'L<S<Z' + psize.to_s )

            @connection.write packet

            code, encoding, size = @connection.read(7).unpack('S<cL<' )
            data = @connection.read size

            decode code, encoding, size, data
        end

        ##
        # This method will be called for every undefined method call
        # of Gibson::Client mapping the method to its opcode and creating
        # its argument payload.
        # For instance a call to:
        #   client = Gibson::Client.new
        #   client.set 0, 'foo', 'bar'
        # Will be executed as:
        #   client.query Protocol::COMMANDS[:set], '0 foo bar'
        def method_missing(name, *arguments)
            if Protocol::COMMANDS.has_key? name 
                query Protocol::COMMANDS[name], arguments.join(' ')
            end
        end

        private :decode_val, :decode_kval, :decode
    end
end
