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


module Rufus
module Tokyo

  #
  # A mixin for structures to respond to tranbegin, trancommit and tranabort
  #
  module Transactions

    #
    # Transaction in a block.
    #
    #   table.transaction do
    #     table['pk0'] => { 'name' => 'Fred', 'age' => '40' }
    #     table['pk1'] => { 'name' => 'Brooke', 'age' => '76' }
    #     table.abort if weather.bad?
    #   end
    #
    # (This is a table example, a classical cabinet won't accept a hash
    # as a value for its entries).
    #
    # If an error or an abort is trigger withing the transaction, it's rolled
    # back. If the block executes successfully, it gets commited.
    #
    def transaction

      return unless block_given?

      begin
        tranbegin
        yield
        trancommit
      rescue Rufus::Tokyo::Transactions::Abort
        tranabort
      rescue Exception => e
        tranabort
        raise e
      end
    end

    #
    # Aborts the enclosing transaction
    #
    # See #transaction
    #
    def abort
      raise Abort, "abort transaction !"
    end

    #
    # Exception used to abort transactions
    #
    class Abort < RuntimeError; end
  end

end
end

