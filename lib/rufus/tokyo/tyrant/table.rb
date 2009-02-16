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

module Rufus
  module Tokyo

    #
    # A Tokyo Cabinet table, but remote...
    #
    #   require 'rufus/tokyo/tyrant'
    #   t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
    #   t['toto'] = { 'name' => 'toto the first', 'age' => '34' }
    #   t['toto']
    #     # => { 'name' => 'toto the first', 'age' => '34' }
    #
    class TyrantTable < Table
      include TyrantMethods

      attr_reader :host, :port

      def initialize (host, port)

        @db = lib.tcrdbnew

        @host = host
        @port = port

        (lib.tcrdbopen(@db, host, port) == 1) ||
          raise("couldn't connect to tyrant at #{host}:#{port}")

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

      protected

      def raise_transaction_nme (method_name)
        raise NoMethodError.new(
          "Tyrant tables don't support transactions", method_name)
      end
    end
  end
end
