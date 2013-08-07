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
    require 'socket'
    require 'timeout'

    class Connection
        ## 
        # Connection default options.
        DEFAULTS = {
            # The UNIX socket path, if this option is set a UNIX socket connection will be used.
            :socket    => '/var/run/gibson.sock',
            # The ip address to connect to, if this option is set a TCP socket connection will be used.
            :address   => nil,
            # The tcp port to connect to.
            :port      => 10128,
            # The connection and I/O timeout in milliseconds.
            :timeout   => 100,
            # If a TCP connection will be used, set this to true to use the SO_KEEPALIVE flag on the socket.
            :keepalive => false
        }

        ##
        # Create a new Connection instance with custom options.
        # If no options are specified, Connection.DEFAULTS will be used.
        # For instance:
        #    Gibson::Client.new                         # will create a connection to the default /var/run/gibson.sock UNIX socket.
        #    Gibson::Client.new :address => '127.0.0.1' # will connect to localhost:10128
        def initialize(opts = {})
            @sock = nil
            @connected = false
            @options = DEFAULTS.merge(opts)
        end

        ##
        # Return true if connection is enstablished, otherwise false.
        def connected?
            @connected
        end

        ##
        # Attempt a connection with the specified options until @options[:timeout]
        # is reached.
        def connect
            Timeout.timeout(@options[:timeout]) do
                if @options[:address] != nil
                    @sock = TCPSocket.new( @options[:address], @options[:port] ) 
                    @sock.setsockopt( Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true )
                    @sock.setsockopt( Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true ) if @options[:keepalive]
                else
                    @sock = UNIXSocket.open( @options[:socket] )
                end

                @connected = true
            end
        end

        ##
        # Close the connection.
        def close
            @sock.close if connected?
        end

        ##
        # Wait for the socket to be in a writable state for @options[:timeout] milliseconds.
        def wait_writable
            IO.select(nil, [@sock], nil, @options[:timeout] ) || raise(Timeout::Error, "IO timeout")
        end

        ##
        # Wait for the socket to be in a readable state for @options[:timeout] milliseconds.
        def wait_readable
            IO.select( [@sock], nil, nil, @options[:timeout] ) || raise(Timeout::Error, "IO timeout")
        end

        ##
        # Write data to the socket.
        def write(data)
            wait_writable
            @sock.write data
        end

        ##
        # Read specified amount of data from the socket.
        def read(n)
            wait_readable
            @sock.recv n
        end
    end
end
