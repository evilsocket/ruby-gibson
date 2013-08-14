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

    ##
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

    ##
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

      decode code, encoding, size, StringIO.new(data)
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
