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

require 'rufus/tokyo/util'


module Rufus::Tokyo

  #
  # A 'table' a table database.
  #
  #   http://alpha.mixi.co.jp/blog/?p=290
  #   http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi
  #
  class Table
    include TokyoContainerMixin

    def self.lib
      Rufus::Tokyo::CabinetLib
    end
    def lib
      self.class.lib
    end

    def initialize (*args)

      path = args.first # car
      params = args[1..-1] # cdr

      mode = compute_open_mode(params)

      @db = lib.tctdbnew

      (lib.tctdbopen(@db, path, compute_open_mode(params)) == 1 ) || raise_error
    end

    #
    # Closes the table (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close
      result = lib.tctdbclose(@db)
      lib.tctdbdel(@db)
      (result == 1)
    end

    #
    # Generates a unique id (in the context of this Table instance)
    #
    def generate_unique_id
      lib.tctdbgenuid(@db)
    end
    alias :genuid :generate_unique_id

    #
    # Accepts a variable number of arguments, at least two. First one
    # is the primary key of the record, the others are the columns.
    #
    # One can also directly write
    #
    #   table['one'] = [ 'name', 'toto', 'age', '33' ]
    #   table['two'] = [ 'name', 'fred', 'age', '45' ]
    #
    # instead of
    #
    #   table.tabbed_put('one', 'name', 'toto', 'age', '33')
    #   table.tabbed_put('two', 'name', 'fred', 'age', '45')
    #
    # beware : inserting an array uses a tab separator...
    #
    def tabbed_put (pk, *args)

      cols = args.collect { |e| e.to_s }.join("\t")

      (lib.tctdbput3(@db, pk, cols) == 1) || raise_error

      args
    end

    #
    # Inserts a record in the table db
    #
    #   table['pk0'] = [ 'name', 'fred', 'age', '45' ]
    #   table['pk1'] = { 'name' => 'jeff', 'age' => '46' }
    #
    def []= (pk, h_or_a)

      return tabbed_put(pk, *h_or_a) if h_or_a.is_a?(Array)

      pklen = lib.strlen(pk)

      m = Rufus::Tokyo::Map.from_h(h_or_a)

      r = lib.tctdbput(@db, pk, pklen, m.pointer)

      m.free

      (r == 1) || raise_error

      h_or_a
    end

    #
    # Removes an entry in the table
    #
    # (might raise an error if the delete itself failed, but returns nil
    # if there was no entry for the given key)
    #
    def delete (k)
      v = self[k]
      return nil unless v
      (lib.tctdbout2(@db, k) == 1) || raise_error
      v
    end

    #
    # Removes all records in this table database
    #
    def clear
      (lib.tctdbvanish(@db) == 1) || raise_error
    end

    #
    # Returns the value (as a Ruby Hash) else nil
    #
    def [] (k)
      m = lib.tctdbget(@db, k, lib.strlen(k))
      return nil if m.address == 0 # :( too bad, but it works
      Rufus::Tokyo::Map.to_h(m) # which frees the map
    end

    #
    # Returns the number of records in this table db
    #
    def size
      lib.tctdbrnum(@db)
    end

    protected

    #
    # Obviously something got wrong, let's ask the db about it and raise
    # a TokyoError
    #
    def raise_error

      err_code = lib.tctdbecode(@db)
      err_msg = lib.tctdberrmsg(err_code)

      raise TokyoError, "(err #{err_code}) #{err_msg}"
    end
  end
end

