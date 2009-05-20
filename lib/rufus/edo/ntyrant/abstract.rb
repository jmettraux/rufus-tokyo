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


require 'tokyotyrant' # gem install careo-tokyotyrant

require 'rufus/edo/error'
require 'rufus/edo/cabcore'
require 'rufus/tokyo/ttcommons'


module Rufus::Edo

  #
  # Connecting to a 'classic' Tokyo Tyrant server remotely
  #
  #   require 'rufus/edo/ntyrant'
  #   t = Rufus::Edo::NetTyrant.new('127.0.0.1', 44001)
  #   t['toto'] = 'blah blah'
  #   t['toto'] # => 'blah blah'
  #
  class NetTyrant

    include Rufus::Edo::CabinetCore
    include Rufus::Tokyo::TyrantCommons

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
    #    require 'rufus/edo/ntyrant'
    #    db = Rufus::Edo::NetTyrant.new('/tmp/tyrant_socket')
    #    db['a'] = 'alpha'
    #    db.close
    # )
    #
    # To connect to a classic TCP bound Tyrant (port 44001) :
    #
    #   t = Rufus::Edo::NetTyrant.new('127.0.0.1', 44001)
    #
    def initialize (host, port=0)

      @host = host
      @port = port

      @db = TokyoTyrant::RDB.new
      @db.open(host, port) || raise_error

      if self.stat['type'] == 'table'

        @db.close

        raise ArgumentError.new(
          "tyrant at #{host}:#{port} is a table, " +
          "use Rufus::Edo::NetTyrantTable instead to access it.")
      end
    end

    # Returns the 'weight' of the db (in bytes)
    #
    def weight

      self.stat['size']
    end

    # isn't that a bit dangerous ? it creates a file on the server...
    #
    # DISABLED.
    #
    def copy (target_path)

      #@db.copy(target_path)
      raise 'not allowed to create files on the server'
    end

    # Copies the current cabinet to a new file.
    #
    # Does it by copying each entry afresh to the target file. Spares some
    # space, hence the 'compact' label...
    #
    def compact_copy (target_path)

      raise NotImplementedError.new('not creating files locally')
    end

    # Deletes all the entries whose keys begin with the given prefix
    #
    def delete_keys_with_prefix (prefix)

      @db.misc('outlist', @db.fwmkeys(prefix, -1)) # -1 for no limits
      nil
    end

    # Given a list of keys, returns a Hash { key => value } of the
    # matching entries (in one sweep).
    #
    def lget (keys)

      Hash[*@db.misc('getlist', keys)]
    end

    # Merges the given hash into this Tyrant and returns self.
    #
    def merge! (hash)

      @db.misc('putlist', hash.inject([]) { |l, (k, v)| l << k; l << v; l })
      self
    end
    alias :lput :merge!

    # Given a list of keys, deletes all the matching entries (in one sweep).
    #
    def ldelete (keys)

      @db.misc('outlist', keys)
      nil
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

      @db.ext(func_name.to_s, key.to_s, value.to_s, compute_ext_opts(opts))
    end

    def addint (key, n)
      @db.addint(key, n)
    end

    protected

    def do_stat #:nodoc#
      @db.stat
    end
  end
end

