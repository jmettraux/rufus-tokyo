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


module Rufus::Tokyo

  #
  # A 'table' a table database.
  #
  #   http://alpha.mixi.co.jp/blog/?p=290
  #   http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi
  #
  class Table
    include CabinetLibMixin
    include TokyoContainerMixin

    def initialize (*args)

      path = args.first # car
      params = args[1..-1] # cdr

      mode = compute_open_mode(params)

      @db = self.lib.tctdbnew

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

    def query (&block)
      q = TableQuery.new(self)
      block.call(q)
      q.run
    end

    def pointer
      @db
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

  #
  # A query on a Tokyo Cabinet table db
  #
  class TableQuery
    include CabinetLibMixin

    OPERATORS = {

      # strings...

      :streq => 1 << 0, # string equality
      :eq => 1 << 0,

      :strinc => 1 << 1, # string include
      :strbw => 1 << 2, # string begins with
      :strew => 1 << 3, # string ends with

      :strand => 1 << 4, # string which include all the tokens in the given exp
      :and => 1 << 4,

      :stror => 1 << 5, # string which include at least one of the tokens
      :or => 1 << 5,

      :stroreq => 1 << 6, # string which is equal to at least one token

      :strorrx => 1 << 7, # string which matches the given regex
      :matches => 1 << 7,

      # numbers...

      :numgt => 1 << 8, # greater than
      :gt => 1 << 8,
      :numge => 1 << 9, # greater or equal
      :ge => 1 << 9,
      :numlt => 1 << 10, # greater or equal
      :lt => 1 << 10,
      :numle => 1 << 11, # greater or equal
      :le => 1 << 11,
      :numbt => 1 << 12, # a number between two tokens in the given exp
      :bt => 1 << 12,

      :numoreq => 1 << 13, # number which is equal to at least one token
    }

    TDQQCNEGATE = 1 << 24
    TDQQCNOIDX = 1 << 25

    def initialize (table)
      @table = table
      @query = lib.tctdbqrynew(@table.pointer)
    end

    def add (colname, operator, val, negate=false)
      op = OPERATORS[operator]
      op = op | TDQQCNEGATE if negate
      lib.tctdbqryaddcond(@query, colname, OPERATORS[operator], val)
    end

    def run
      TableResultSet.new(@table, lib.tctdbqrysearch(@query))
    end
  end

  class TableResultSet
    include CabinetLibMixin
    include Enumerable

    def initialize (table, list_pointer)
      @table = table
      @list = list_pointer
    end

    def size
      lib.tclistnum(@list)
    end

    def each
      (0..size-1).each do |i|
        pk = lib.tclistval2(@list, i)
        yield @table[pk]
      end
    end

    #
    # Returns an array of hashes
    #
    def to_a
      collect { |m| m }
    end

    def free
      lib.tclistdel(@list)
      @list = nil
    end
  end
end

