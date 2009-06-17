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


require 'rufus/tokyo/query'
require 'rufus/tokyo/transactions'


module Rufus::Edo

  #
  # Methods common to the two table classes (cabinet + ntyrant) found in
  # Rufus::Edo
  #
  module TableCore

    include Rufus::Tokyo::HashMethods
    include Rufus::Tokyo::Transactions

    # Closes the table (and frees the datastructure allocated for it),
    # raises an exception in case of failure.
    #
    def close
      @db.close || raise_error
    end

    # Generates a unique id (in the context of this Table instance)
    #
    def generate_unique_id
      @db.genuid
    end
    alias :genuid :generate_unique_id

    INDEX_TYPES = {
      :lexical => 0,
      :decimal => 1,
      :void => 9999,
      :remove => 9999,
      :keep => 1 << 24
    }

    # Sets an index on a column of the table.
    #
    # Types maybe be :lexical or :decimal, use :keep to "add" and
    # :remove (or :void) to "remove" an index.
    #
    # If column_name is :pk or "", the index will be set on the primary key.
    #
    # Raises an exception in case of failure.
    #
    def set_index (column_name, *types)

      column_name = '' if column_name == :pk

      i = types.inject(0) { |i, t| i = i | INDEX_TYPES[t]; i }

      @db.setindex(column_name, i) || raise_error
    end

    # Inserts a record in the table db
    #
    #   table['pk0'] = [ 'name', 'fred', 'age', '45' ]
    #   table['pk1'] = { 'name' => 'jeff', 'age' => '46' }
    #
    # Accepts both a hash or an array (expects the array to be of the
    # form [ key, value, key, value, ... ] else it will raise
    # an ArgumentError)
    #
    # Raises an error in case of failure.
    #
    def []= (pk, h_or_a)

      m = h_or_a.is_a?(Hash) ? h_or_a : Hash[*h_or_a]

      verify_value(m)

      @db.put(pk, m) || raise_error
    end

    # Removes an entry in the table
    #
    # (might raise an error if the delete itself failed, but returns nil
    # if there was no entry for the given key)
    #
    # Raises an error if something went wrong
    #
    def delete (k)

      # have to work around... :(

      val = @db[k]
      return nil unless val

      @db.out(k) || raise_error
      val
    end

    # Removes all records in this table database
    #
    # Raises an error if something went wrong
    #
    def clear

      @db.vanish || raise_error
    end

    # Returns an array of all the primary keys in the table
    #
    # With no options given, this method will return all the keys (strings)
    # in a Ruby array.
    #
    #   :prefix --> returns only the keys who match a given string prefix
    #
    #   :limit --> returns a limited number of keys
    #
    def keys (options={})

      if pref = options[:prefix]

        @db.fwmkeys(pref, options[:limit] || -1)

      else

        limit = options[:limit] || -1
        limit = nil if limit < 1

        @db.iterinit

        l = []

        while (k = @db.iternext)
          break if limit and l.size >= limit
          l << k
        end

        l
      end
    end

    # Deletes all the entries whose key begin with the given prefix.
    #
    def delete_keys_with_prefix (prefix)

      ks = @db.fwmkeys(prefix, -1) # -1 for no limit
      ks.each { |k| self.delete(k) }
    end

    # No 'misc' methods for the table library, so this lget is equivalent
    # to calling get for each key. Hoping later versions of TC will provide
    # a mget method.
    #
    def lget (keys)

      # TODO : maybe investigate a query on the column 'primary_key' ?

      keys.inject({}) { |h, k| v = self[k]; h[k] = v if v; h }
    end

    # Returns the number of records in this table db
    #
    def size

      @db.rnum
    end

    # Prepares a query instance (block is optional)
    #
    def prepare_query (&block)

      q = TableQuery.new(table_query_class, self)
      block.call(q) if block

      q
    end

    # Prepares and runs a query, returns an array of hashes (all Ruby)
    # (takes care of freeing the query and the result set structures)
    #
    def query (&block)

      prepare_query(&block).run
    end

    # Prepares, runs AND delete all the matching records.
    #
    def query_delete (&block)

      prepare_query(&block).delete
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction begin'.
    #
    def tranbegin

      @db.tranbegin || raise_error
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction commit'.
    #
    def trancommit

      @db.trancommit || raise_error
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction abort'.
    #
    def tranabort

      @db.tranabort || raise_error
    end

    # Returns the underlying 'native' Ruby object (of the class devised by
    # Hirabayashi-san)
    #
    def original

      @db
    end

    protected

    # Returns the value (as a Ruby Hash) else nil
    #
    # (the actual #[] method is provided by HashMethods)
    #
    def get (k)

      @db.get(k)
    end

    # Obviously something went wrong, let's ask the db about it and raise
    # an EdoError
    #
    def raise_error

      err_code = @db.ecode
      err_msg = @db.errmsg(err_code)

      raise EdoError.new("(err #{err_code}) #{err_msg}")
    end

    def verify_value (h)

      h.each { |k, v|

        next if k.is_a?(String) and v.is_a?(String)

        raise ArgumentError.new(
          "only String keys and values are accepted " +
          "( #{k.inspect} => #{v.inspect} )")
      }
    end
  end

  #
  # A query on a Tokyo Cabinet table db
  #
  class TableQuery

    include Rufus::Tokyo::QueryConstants

    # Creates a query for a given Rufus::Tokyo::Table
    #
    # Queries are usually created via the #query (#prepare_query #do_query)
    # of the Table instance.
    #
    # Methods of interest here are :
    #
    #   * #add (or #add_condition)
    #   * #order_by
    #   * #limit
    #
    # also
    #
    #   * #pk_only
    #   * #no_pk
    #
    def initialize (query_class, table)

      @table = table
      @query = query_class.new(table.original)

      @opts = {}
    end

    # Adds a condition
    #
    #   table.query { |q|
    #     q.add 'name', :equals, 'Oppenheimer'
    #     q.add 'age', :numgt, 35
    #   }
    #
    # Understood 'operators' :
    #
    #   :streq # string equality
    #   :eq
    #   :eql
    #   :equals
    #
    #   :strinc # string include
    #   :inc # string include
    #   :includes # string include
    #
    #   :strbw # string begins with
    #   :bw
    #   :starts_with
    #   :strew # string ends with
    #   :ew
    #   :ends_with
    #
    #   :strand # string which include all the tokens in the given exp
    #   :and
    #
    #   :stror # string which include at least one of the tokens
    #   :or
    #
    #   :stroreq # string which is equal to at least one token
    #
    #   :strorrx # string which matches the given regex
    #   :regex
    #   :matches
    #
    #   # numbers...
    #
    #   :numeq # equal
    #   :numequals
    #   :numgt # greater than
    #   :gt
    #   :numge # greater or equal
    #   :ge
    #   :gte
    #   :numlt # greater or equal
    #   :lt
    #   :numle # greater or equal
    #   :le
    #   :lte
    #   :numbt # a number between two tokens in the given exp
    #   :bt
    #   :between
    #
    #   :numoreq # number which is equal to at least one token
    #
    def add (colname, operator, val, affirmative=true, no_index=false)

      op = operator.is_a?(Fixnum) ? operator : OPERATORS[operator]
      op = op | TDBQCNEGATE unless affirmative
      op = op | TDBQCNOIDX if no_index

      @query.addcond(colname, op, val)
    end
    alias :add_condition :add

    # Sets the max number of records to return for this query.
    #
    # (If you're using TC >= 1.4.10 the optional 'offset' (skip) parameter
    # is accepted)
    #
    def limit (i, offset=-1)

      @query.respond_to?(:setlimit) ?
        @query.setlimit(i, offset) :
        @query.setmax(i)
    end

    # Sets the sort order for the result of the query
    #
    # The 'direction' may be :
    #
    #   :strasc # string ascending
    #   :strdesc
    #   :asc # string ascending
    #   :desc
    #   :numasc # number ascending
    #   :numdesc
    #
    def order_by (colname, direction=:strasc)

      @query.setorder(colname, DIRECTIONS[direction])
    end

    # When set to true, only the primary keys of the matching records will
    # be returned.
    #
    def pk_only (on=true)

      @opts[:pk_only] = on
    end

    # When set to true, the :pk (primary key) is not inserted in the record
    # (hashes) returned
    #
    def no_pk (on=true)

      @opts[:no_pk] = on
    end

    # Runs this query (returns a TableResultSet instance)
    #
    def run

      @last_resultset = TableResultSet.new(@table, @query.search, @opts)
    end

    # Runs this query AND immediately let the matching records get deleted.
    #
    def delete

      @query.searchout || @table.raise_error
    end

    # Returns the count of results this query return when last run.
    # Returns 0 if the query was not yet run.
    #
    def count

      #@query.count
        # not yet implemented by Hirabayashi-san

      @last_resultset ? @last_resultset.size : 0
    end

    # Frees this data structure
    #
    def free

      # nothing ... :(  I hope there's no memory leak
    end

    alias :close :free
    alias :destroy :free
  end

  #
  # The thing queries return
  #
  class TableResultSet
    include Enumerable

    def initialize (table, primary_keys, query_opts)

      @table = table
      @keys = primary_keys
      @opts = query_opts
    end

    # Returns the count of element in this result set
    #
    def size

      @keys.size
    end

    alias :length :size

    # The classical each
    #
    def each

      @keys.each do |pk|
        if @opts[:pk_only]
          yield(pk)
        else
          val = @table[pk]
          val[:pk] = pk unless @opts[:no_pk]
          yield(val)
        end
      end
    end

    # Returns an array of hashes
    #
    def to_a

      self.collect { |m| m }
    end

    # Frees this query (the underlying Tokyo Cabinet list structure)
    #
    def free

      # nothing to do, kept for similarity with Rufus::Tokyo
    end

    alias :close :free
    alias :destroy :free
  end
end

