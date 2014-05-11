require 'active_support/core_ext/marshal'
require 'active_support/core_ext/string/conversions'

module ActiveSupport
  module Cache
    # A cache store implementation which stores everything on the Gibson cache server.
    #
    # GibsonStore implements the Strategy::LocalCache strategy which implements
    # an in-memory cache inside of a block.
    class GibsonStore < Store
      attr_reader :namespace
      attr_reader :options

      def initialize( namespace, options )
        @options = options.dup
        @namespace = namespace.to_s
        @gibson = Gibson::Client.new @options 

        extend Strategy::LocalCache
      end

      # Deletes all items from the cache.
      def clear(options = nil)
        @gibson.mdel @namespace + "::"
      end

      # Increments an already existing integer value that is stored in the cache.
      def increment(name, amount = 1, options = nil)
        key = expand_key(name)
        amount.times do |v|
          @gibson.inc key
        end
      end

      # Decrements an already existing integer value that is stored in the cache.
      def decrement(name, amount = 1, options = nil)
        key = expand_key(name)
        amount.times do |v|
          @gibson.dec key
        end
      end

      # Deletes multiple values by expression
      def delete_matched(matcher, options = nil)
        key = expand_key(matcher)
        @gibson.mdel key
      end

      # Returns some stats
      def stats
        @gibson.stats
      end

      protected

        def read_entry(key, options)
          key = expand_key(key)

          begin
            cached = @gibson.get key

            Marshal.load(cached)
          rescue Gibson::NotFoundError
            nil
          end
        end

        def write_entry(key, entry, options)
          e = Marshal.dump(entry)

          key = expand_key(key) 

          begin
            @gibson.set( options[:expires_in].to_i, key, e )
            
            true
          rescue
            false
          end
        end

        def delete_entry(key, options)
          key = expand_key(key)

          begin
            @gibson.del key

            true
          rescue
            false
          end
        end

      private 

        def expand_key(v)
          @namespace + "::" + v.to_s.tr( ' ', '_' )
        end
    end
  end
end
