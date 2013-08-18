require 'gibson/protocol'
require 'gibson/connection'
require 'stringio'

##
# Define an utility instance method for the String core class.
class StringIO
  ##
  # Read size bytes and return the first unpacked value given a format.
  def read_unpacked size, format
    read( size ).unpack( format )[0]
  end
end

module Gibson
  class Client
    # Create a new Gibson::Client instance, the options are passed to
    # Gibson::Connection initialize method.
    # 
    # ==== Examples:
    #
    #   Gibson::Client.new                         # will create a connection to the default /var/run/gibson.sock UNIX socket.
    #   Gibson::Client.new :address => '127.0.0.1' # will connect to localhost:10128
    #
    # ==== Options:
    # 
    # - :socket - The UNIX socket path, if this option is set a UNIX socket connection will be used. Default: /var/run/gibson.sock
    # - :address - The ip address to connect to, if this option is set a TCP socket connection will be used. Default: nil
    # - :port - The tcp port to connect to. Default: 10128
    # - :timeout - The connection and I/O timeout in milliseconds. Default: 100
    # - :keepalive - If a TCP connection will be used, set this to true to use the SO_KEEPALIVE flag on the socket. Default: false
    def initialize(opts = {})
      @connection = nil
      @options = opts
    end

    # Create the connection.
    def connect
      @connection = Connection.new( @options )
      @connection.connect
    end

    # Decode a REPL_VAL reply.
    def decode_val( encoding, size, io )
      # plain string
      if encoding == Protocol::ENCODINGS[:plain]
        io.read_unpacked size, 'Z' + size.to_s
        # number
      elsif encoding == Protocol::ENCODINGS[:number]
        unpacker = size == 4 ? 'l<' : 'q<'
        io.read_unpacked size, unpacker
      else
        raise 'Unknown data encoding.'
      end
    end

    # Decode a REPL_KVAL reply.
    def decode_kval( io, size )
      count = io.read_unpacked 4, 'L<'
      obj   = {}

      count.times do |i|
        klen  = io.read_unpacked 4, 'L<' 
        key   = io.read_unpacked klen, 'a' + klen.to_s
        enc   = io.read_unpacked 1, 'c'
        vsize = io.read_unpacked 4, 'L<'

        obj[key] = decode Protocol::REPLIES[:val], enc, vsize, io
      end

      obj
    end

    # Reply decoding wrapper.
    def decode( code, encoding, size, io )
      if code == Protocol::REPLIES[:val]
        decode_val encoding, size, io

      elsif code == Protocol::REPLIES[:kval]
        decode_kval io, size

      elsif code == Protocol::REPLIES[:ok]
        true

      elsif Protocol.error? code
        raise Protocol::ERRORS[code]

      else
        io
      end
    end

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

      decode code, encoding, size, StringIO.new(data)
    end

    # Map every command => opcode to an instance method. 
    Protocol::COMMANDS.each do |name,opcode|
      define_method(name) do |*args|
        query opcode, args.join(' ')
      end
    end

    private :decode_val, :decode_kval, :decode
  end
end
