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
  # A Tokyo Cabinet table, but remote...
  #
  #   require 'rufus/tokyo/tyrant'
  #   t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
  #   t['toto'] = { 'name' => 'toto the first', 'age' => '34' }
  #   t['toto']
  #     # => { 'name' => 'toto the first', 'age' => '34' }
  #
  # Most of the methods of this TyrantTable class are defined in the parent
  # class Rufus::Tokyo::Table.
  #
  class TyrantTable < Table

    include TyrantCommons
    include Outlen
    include Ext


    attr_reader :host, :port

    # Connects to the Tyrant table listening at the given host and port.
    #
    # You start such a Tyrant with :
    #
    #   ttserver -port 44502 data.tct
    #
    # and then :
    #
    #   require 'rufus/tokyo/tyrant'
    #   t = Rufus::Tokyo::TyrantTable.new('127.0.0.1', 44502)
    #   t['client0'] = { 'name' => 'Heike no Kyomori', 'country' => 'jp' }
    #   t.close
    #
    #
    # You can start a Tokyo Tyrant and make it listen to a unix socket (not TCP)
    # with :
    #
    #   ttserver -host /tmp/table_socket -port 0 data.tct
    #
    # then :
    #
    #   require 'rufus/tokyo/tyrant'
    #   t = Rufus::Tokyo::TyrantTable.new('/tmp/table_socket')
    #   t['client0'] = { 'name' => 'Theodore Roosevelt', 'country' => 'usa' }
    #   t.close
    #
    def initialize (host, port=0)

      @db = lib.tcrdbnew

      @host = host
      @port = port

      (lib.tcrdbopen(@db, host, port) == 1) ||
        raise(TokyoError.new("couldn't connect to tyrant at #{host}:#{port}"))

      if self.stat['type'] != 'table'

        self.close

        raise ArgumentError.new(
          "tyrant at #{host}:#{port} is a not table, " +
          "use Rufus::Tokyo::Tyrant instead to access it.")
      end
    end

    #
    # using the cabinet lib
    #
    def lib
      TyrantLib
    end

    def transaction #:nodoc#
      raise_transaction_nme('transaction')
    end
    def abort #:nodoc#
      raise_transaction_nme('abort')
    end
    def tranbegin #:nodoc#
      raise_transaction_nme('tranbegin')
    end
    def trancommit #:nodoc#
      raise_transaction_nme('trancommit')
    end
    def tranabort #:nodoc#
      raise_transaction_nme('tranabort')
    end

    #--
    # Doesn't work properly, tcrdbmisc doesn't return something leveragable :(
    #
    #def lget (keys)
    #  call_misc('getlist', Rufus::Tokyo::List.new(keys))
    #end
    #++

    protected

    def raise_transaction_nme (method_name)

      raise NoMethodError.new(
        "Tyrant tables don't support transactions", method_name)
    end

    # Returns the raw stat string from the Tyrant server.
    #
    def do_stat

      lib.tcrdbstat(@db) # note : this is using tcrdbstat
    end

    #--
    # (see #lget's comment)
    #
    # wrapping tcadbmisc or tcrdbmisc
    # (and taking care of freeing the list_pointer)
    #
    #def call_misc (function, list_pointer)
    #  list_pointer = list_pointer.pointer \
    #    if list_pointer.is_a?(Rufus::Tokyo::List)
    #  begin
    #    l = lib.tcrdbmisc(@db, function, 0, list_pointer)
    #      # opts always to 0 for now
    #    raise "function '#{function}' failed" unless l
    #    Rufus::Tokyo::List.new(l).release
    #  ensure
    #    Rufus::Tokyo::List.free(list_pointer)
    #  end
    #end
    #++
  end
end
