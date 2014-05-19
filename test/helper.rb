$:.unshift File.expand_path("../lib", File.dirname(__FILE__))
$:.unshift File.expand_path(File.dirname(__FILE__))

require "test/unit"
require "logger"
require "stringio"

begin
  require "ruby-debug"
rescue LoadError
end

$VERBOSE = true

ENV["conn"] ||= "ruby"

require "gibson"

OPTIONS = {:socket => '/var/run/gibson.sock', :timeout => 1000}

module Client
  def setup
    begin
      @gibson = Gibson::Client.new OPTIONS
      # make sure the connection is tested and enstablished
      @gibson.ping 
    rescue
      puts <<-EOS

       Cannot connect to Gibson.

       Make sure Gibson is running on localhost, socket #{OPTIONS[:socket]},
       if you are running the test suite from the "tests" folder of the gibson
       source release, run:

       sudo ./gibson -c debian/etc/gibson/gibson.conf --daemonize 0 --logfile /dev/stdout --loglevel 0 --gc_ratio 1s --max_mem_cron 1s --expired_cron 1

       To install gibson:
         visit <http://gibson-db.in/>.
      EOS
      exit 1
    end
  end

  def teardown
    if @gibson
      begin
        @gibson.munlock 'test'
        @gibson.mdel "test"
        @gibson.end
      rescue

      end
    end
  end
end

