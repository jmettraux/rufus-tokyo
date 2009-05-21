#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'rufus/tokyo/ttcommons'


module Rufus::Tokyo

  #
  # Connecting to a 'classic' tyrant server remotely
  #
  #   require 'rufus/tokyo/tyrant'
  #   t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
  #   t['toto'] = 'blah blah'
  #   t['toto'] # => 'blah blah'
  #
  class Tyrant < Cabinet

    include TyrantCommons

    attr_reader :host, :port

    # Connects to a given Tokyo Tyrant server.
    #
    # Note that if the port is not specified, the host parameter is expected
    # to hold the path to a unix socket (not a TCP socket).
    #
    # (You can start a unix socket listening Tyrant with :
    #
    #    ttserver -host /tmp/tyrant_socket -port 0 data.tch
    #
    #  and then connect to it with rufus-tokyo via :
    #
    #    require 'rufus/tokyo/tyrant'
    #    db = Rufus::Tokyo::Tyrant.new('/tmp/tyrant_socket')
    #    db['a'] = 'alpha'
    #    db.close
    # )
    #
    # To connect to a classic TCP bound Tyrant (port 44001) :
    #
    #   t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
    #
    def initialize (host, port=0)

      @db = lib.tcrdbnew

      @host = host
      @port = port

      (lib.tcrdbopen(@db, host, port) == 1) ||
        raise("couldn't connect to tyrant at #{host}:#{port}")

      if self.stat['type'] == 'table'

        self.close

        raise ArgumentError.new(
          "tyrant at #{host}:#{port} is a table, " +
          "use Rufus::Tokyo::TyrantTable instead to access it.")
      end
    end

    # Using the tyrant lib
    #
    def lib
      TyrantLib
    end

    # isn't that a bit dangerous ? it creates a file on the server...
    #
    # DISABLED.
    #
    def copy (target_path)
      #@db.copy(target_path)
      raise 'not allowed to create files on the server'
    end

    # Calls a lua embedded function
    # (http://tokyocabinet.sourceforge.net/tyrantdoc/#luaext)
    #
    # Options are :global_locking and :record_locking
    #
    # Returns the return value of the called function.
    #
    # Nil is returned in case of failure.
    #
    def ext (func_name, key, value, opts={})

      lib.tcrdbext2(
        @db, func_name.to_s, compute_ext_opts(opts), key.to_s, value.to_s
      ) rescue nil
    end

    # Tyrant databases DO NOT support the 'defrag' call. Calling this method
    # will raise an exception.
    #
    def defrag

      raise NotImplementedError.new(
        "method defrag is not supported for Tyrant databases")
    end

    protected

    def do_call_misc (function, list_pointer)

      lib.tcrdbmisc(@db, function, 0, list_pointer)
        # opts always to 0 for now
    end

    # Returns the raw stat string from the Tyrant server.
    #
    def do_stat

      lib.tcrdbstat(@db)
    end
  end
end

