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
