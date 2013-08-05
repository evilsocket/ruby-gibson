Ruby Gibson client
========================

A pure Ruby Gibson client library.

<http://gibson-db.in/>

Supported Ruby versions and implementations
------------------------------------------------

This module should work identically on:

 * JRuby 1.6+
 * Ruby 1.9.2+
 * Ruby 1.8.7+
 * Rubinius 2.0

If you have problems, please enter an issue.

Installation and Usage
------------------------

You can verify your installation using this piece of code:

    gem install gibson

And

    require 'gibson'
    g = Gibson::Client.new
    g.set 0, 'foo', 'bar'
    p g.get 'foo'

Connection
----------

Create a Client object to start working.

    require 'gibson'

    gibson = Gibson::Client.new

The following options can be used in the constructor:

* **socket**: String, the path of the unix socket to connect to, default to /var/run/gibson.sock.
* **address**: String, the tcp address to connect to, setting this option will exclude the :socket option, default to nil.
* **port**: Integer, the tcp port of Gibson instance, default to 10128.
* **timeout**: Integer, timeout in milliseconds for socket I/O, default to 100.
* **keepalive**: Boolean, true to set SO_KEEPALIVE option on the tcp socket, default true.

Tcp connection example:

    gibson = Gibson::Client.new :address => 'localhost'

Custom unix socket connection example with 50ms timeout:

    gibson = Gibson::Client.new :socket => '/tmp/socket', :timeout => 50

Runtime Errors
--------------

Every Gibson protocol error is mapped to a RuntimeError derived class.

* **GenericError** Generic protocol error.
* **NotFoundError** Key or prefix not found.
* **NaNError** The object is not a number.
* **OutOfMemoryError** Server is out of memory.
* **LockedError** Object is locked.

Methods
-------

After connecting, you can start to make requests.
    
    # will retrieve the 'key' value
    gibson.get 'key'

    # create ( or replace ) a value with a TTL of 3600 seconds.
    # set the TTL to zero and the value will never expire. 
    gibson.set 3600, 'key', 'value'
    
    # delete a key from cache.
    gibson.del 'key'

    # will print server stats
	gibson.stats.each do |name,value|
        puts "#{name}: #{value}"
    end

Every available command is automatically mapped to a client method, so follow the 
[official reference](http://gibson-db.in/commands.php) of Gibson commands.

Once you're done, close the connection.

	gibson.close

License
---

Released under the BSD license.  
Copyright &copy; 2013, Simone Margaritelli 
<evilsocket@gmail.com>  

<http://www.evilsocket.net/>
All rights reserved.
