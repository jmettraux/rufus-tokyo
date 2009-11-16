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
require 'rufus/tokyo/tyrant/ext'

module Rufus::Tokyo

  #
  # Connecting to a 'classic' tyrant server remotely
  #
  #   require 'rufus/tokyo/tyrant'
  #   t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
  #   t['toto'] = 'blah blah'
  #   t['toto'] # => 'blah blah'
  #
  # == Cabinet methods not available to Tyrant
  #
  # The #defrag method is not available for Tyrant.
  #
  # More importantly transaction related methods are not available either.
  # No transactions for Tokyo Tyrant.
  #
  class Tyrant < Cabinet

    include TyrantCommons
    include Ext
    include NoTransactions

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
    #
    # == :default and :default_proc
    #
    # Much like a Ruby Hash, a Tyrant accepts a default value or a default_proc
    #
    #   db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 1978, :default => 'xxx')
    #   db['fred'] = 'Astaire'
    #   p db['fred'] # => 'Astaire'
    #   p db['ginger'] # => 'xxx'
    #
    #   db = Rufus::Tokyo::Tyrant.new(
    #     '127.0.0.1',
    #     1978,
    #     :default_proc => lambda { |cab, key| "not found : '#{k}'" }
    #   p db['ginger'] # => "not found : 'ginger'"
    #
    # The first arg passed to the default_proc is the tyrant itself, so this
    # opens up interesting possibilities.
    #
    def initialize (host, port=0, params={})

      @db = lib.tcrdbnew

      @host = host
      @port = port

      lib.tcrdbopen(@db, host, port) || raise(
        TokyoError.new("couldn't connect to tyrant at #{host}:#{port}"))

      if self.stat['type'] == 'table'

        self.close

        raise ArgumentError.new(
          "tyrant at #{host}:#{port} is a table, " +
          "use Rufus::Tokyo::TyrantTable instead to access it.")
      end

      #
      # default value|proc

      self.default = params[:default]
      @default_proc ||= params[:default_proc]
    end

    # Using the tyrant lib
    #
    def lib

      TyrantLib
    end

    # Tells the Tyrant server to create a copy of itself at the given (remote)
    # target_path.
    #
    # Returns true when successful.
    #
    # Note : if you started your ttserver with a path like "tyrants/data.tch"
    # you have to provide a target path in the same subdir, like
    # "tyrants/data_prime.tch".
    #
    def copy (target_path)

      lib.abs_copy(@db, target_path) || raise_error
    end

    # Tyrant databases DO NOT support the 'defrag' call. Calling this method
    # will raise an exception.
    #
    def defrag

      raise(NoMethodError.new("Tyrant dbs don't support #defrag"))
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

    def raise_error

      code = lib.abs_ecode(@db)
      message = lib.abs_errmsg(@db, code)
      raise TokyoError.new("(err #{code}) #{message}")
    end
  end
end

