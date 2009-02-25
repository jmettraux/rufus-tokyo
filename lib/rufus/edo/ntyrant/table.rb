#
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
#++
#

#
# "made in Japan"
#
# jmettraux@gmail.com
#

require 'tokyotyrant'

require 'rufus/edo/error'
require 'rufus/edo/tabcore'
require 'rufus/tokyo/stats'


module Rufus::Edo

  #
  # A Tokyo Cabinet table, but remote...
  #
  #   require 'rufus/edo/ntyrant'
  #   t = Rufus::Edo::NetTyrant.new('127.0.0.1', 44001)
  #   t['toto'] = { 'name' => 'toto the first', 'age' => '34' }
  #   t['toto']
  #     # => { 'name' => 'toto the first', 'age' => '34' }
  #
  # NOTE : The advantage of this class is that it leverages the TokyoTyrant.rb
  # provided by Hirabayashi-san. It's pure Ruby, it's slow but works everywhere
  # without the need for Tokyo Cabinet and Tyrant C libraries.
  #
  class NetTyrantTable

    include Rufus::Edo::TableCore
    include Rufus::Tokyo::TyrantStats

    attr_reader :host, :port

    #
    # Connects to the Tyrant table listening at the given host and port.
    #
    # You start such a Tyrant with :
    #
    #   ttserver -port 44502 data.tct
    #
    # and then :
    #
    #   require 'rufus/edo/ntyrant'
    #   t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 44502)
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
    #   require 'rufus/edo/ntyrant'
    #   t = Rufus::Edo::NetTyrantTable.new('/tmp/table_socket')
    #   t['client0'] = { 'name' => 'Theodore Roosevelt', 'country' => 'usa' }
    #   t.close
    #
    def initialize (host, port=0)

      @host = host
      @port = port

      @db = TokyoTyrant::RDBTBL.new
      @db.open(host, port) || raise_error

      if self.stat['type'] != 'table'

        @db.close

        raise ArgumentError.new(
          "tyrant at #{host}:#{port} is not a table, " +
          "use Rufus::Edo::NetTyrant instead to access it.")
      end
    end

    def transaction #:nodoc#
      raise NoMethodError.new("NetTyrant : transactions not supported")
    end
    def abort #:nodoc#
      raise NoMethodError.new("NetTyrant : transactions not supported")
    end
    def tranbegin #:nodoc#
      raise NoMethodError.new("NetTyrant : transactions not supported")
    end
    def trancommit #:nodoc#
      raise NoMethodError.new("NetTyrant : transactions not supported")
    end
    def tranabort #:nodoc#
      raise NoMethodError.new("NetTyrant : transactions not supported")
    end

    protected

    def table_query_class #:nodoc#

      TokyoTyrant::RDBQRY
    end

    def do_stat #:nodoc#

      @db.stat
    end
  end
end

