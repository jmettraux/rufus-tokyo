#--
# Copyright (c) 2009-2010, John Mettraux, jmettraux@gmail.com
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


require 'rufus/tokyo/utils'
require 'rufus/tokyo/query'
require 'rufus/tokyo/config'
require 'rufus/tokyo/transactions'
require 'rufus/tokyo/openable'


module Rufus::Tokyo

  #
  # A 'table' a table database.
  #
  #   http://alpha.mixi.co.jp/blog/?p=290
  #   http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi
  #
  # A short example :
  #
  #   require 'rubygems'
  #   require 'rufus/tokyo/cabinet/table'
  #
  #   t = Rufus::Tokyo::Table.new('table.tct')
  #
  #   t['pk0'] = { 'name' => 'alfred', 'age' => '22' }
  #   t['pk1'] = { 'name' => 'bob', 'age' => '18' }
  #   t['pk2'] = { 'name' => 'charly', 'age' => '45' }
  #   t['pk3'] = { 'name' => 'doug', 'age' => '77' }
  #   t['pk4'] = { 'name' => 'ephrem', 'age' => '32' }
  #
  #   p t.query { |q|
  #     q.add_condition 'age', :numge, '32'
  #     q.order_by 'age'
  #     q.limit 2
  #   }
  #     # => [ {"name"=>"ephrem", :pk=>"pk4", "age"=>"32"},
  #     #      {"name"=>"charly", :pk=>"pk2", "age"=>"45"} ]
  #
  #   t.close
  #
  class Table

    include HashMethods
    include CabinetConfig
    extend  Openable

    include Transactions
      # this class has tranbegin/trancommit/tranabort so let's include the
      # transaction mixin

    # Creates a Table instance (creates or opens it depending on the args)
    #
    # For example,
    #
    #   t = Rufus::Tokyo::Table.new('table.tct')
    #     # '.tct' suffix is a must
    #
    # will create the table.tct (or simply open it if already present)
    # and make sure we have write access to it.
    #
    # == parameters
    #
    # Parameters can be set in the path or via the optional params hash (like
    # in Rufus::Tokyo::Cabinet)
    #
    #   * :mode    a set of chars ('r'ead, 'w'rite, 'c'reate, 't'runcate,
    #              'e' non locking, 'f' non blocking lock), default is 'wc'
    #   * :opts    a set of chars ('l'arge, 'd'eflate, 'b'zip2, 't'cbs)
    #              (usually empty or something like 'ld' or 'lb')
    #
    #   * :bnum    number of elements of the bucket array
    #   * :apow    size of record alignment by power of 2 (defaults to 4)
    #   * :fpow    maximum number of elements of the free block pool by
    #              power of 2 (defaults to 10)
    #   * :mutex   when set to true, makes sure only 1 thread at a time
    #              accesses the table (well, Ruby, global thread lock, ...)
    #
    #   * :rcnum   specifies the maximum number of records to be cached.
    #              If it is not more than 0, the record cache is disabled.
    #              It is disabled by default.
    #   * :lcnum   specifies the maximum number of leaf nodes to be cached.
    #              If it is not more than 0, the default value is specified.
    #              The default value is 2048.
    #   * :ncnum   specifies the maximum number of non-leaf nodes to be
    #              cached. If it is not more than 0, the default value is
    #              specified. The default value is 512.
    #
    #   * :xmsiz   specifies the size of the extra mapped memory. If it is
    #              not more than 0, the extra mapped memory is disabled.
    #              The default size is 67108864.
    #
    #   * :dfunit  unit step number. If it is not more than 0,
    #              the auto defragmentation is disabled. (Since TC 1.4.21)
    #
    # Some examples :
    #
    #   t = Rufus::Tokyo::Table.new('table.tct')
    #   t = Rufus::Tokyo::Table.new('table.tct#mode=r')
    #   t = Rufus::Tokyo::Table.new('table.tct', :mode => 'r')
    #   t = Rufus::Tokyo::Table.new('table.tct#opts=ld#mode=r')
    #   t = Rufus::Tokyo::Table.new('table.tct', :opts => 'ld', :mode => 'r')
    #
    def initialize (path, params={})

      conf = determine_conf(path, params, :table)

      @db = lib.tctdbnew

      #
      # tune table

      libcall(:tctdbsetmutex) if conf[:mutex]

      libcall(:tctdbtune, conf[:bnum], conf[:apow], conf[:fpow], conf[:opts])

      # TODO : set indexes here... well, there is already #set_index
      #conf[:indexes]...

      libcall(:tctdbsetcache, conf[:rcnum], conf[:lcnum], conf[:ncnum])

      libcall(:tctdbsetxmsiz, conf[:xmsiz])

      libcall(:tctdbsetdfunit, conf[:dfunit]) \
        if lib.respond_to?(:tctdbsetdfunit) # TC >= 1.4.21

      #
      # open table

      @path = conf[:path]

      libcall(:tctdbopen, @path, conf[:mode])

      #
      # no default

      @default_proc = nil
    end

    # Using the cabinet lib
    #
    def lib

      CabinetLib
    end

    # Returns the path to the table.
    #
    def path

      @path
    end

    # Closes the table (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close

      result = lib.tab_close(@db)
      lib.tab_del(@db)

      result
    end

    # Generates a unique id (in the context of this Table instance)
    #
    def generate_unique_id

      lib.tab_genuid(@db)
    end
    alias :genuid :generate_unique_id

    INDEX_TYPES = {
      :lexical => 0,
      :decimal => 1,
      :token => 2,
      :qgram => 3,
      :opt => 9998,
      :optimized => 9998,
      :void => 9999,
      :remove => 9999,
      :keep => 1 << 24
    }

    # Sets an index on a column of the table.
    #
    # Types maybe be :lexical or :decimal.
    #
    # Recently (TC 1.4.26 and 1.4.27) inverted indexes have been added,
    # they are :token and :qgram. There is an :opt index as well.
    #
    # Sorry couldn't find any good doc about those inverted indexes apart from :
    #
    #   http://alpha.mixi.co.jp/blog/?p=1147
    #   http://www.excite-webtl.jp/world/english/web/?wb_url=http%3A%2F%2Falpha.mixi.co.jp%2Fblog%2F%3Fp%3D1147&wb_lp=JAEN&wb_dis=2&wb_submit=+%96%7C+%96%F3+
    #
    # Use :keep to "add" and
    # :remove (or :void) to "remove" an index.
    #
    # If column_name is :pk or "", the index will be set on the primary key.
    #
    # Returns true in case of success.
    #
    def set_index (column_name, *types)

      column_name = column_name == :pk ? '' : column_name.to_s

      ii = types.inject(0) { |i, t| i = i | INDEX_TYPES[t]; i }

      lib.tab_setindex(@db, column_name, ii)
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

      pk = pk.to_s
      h_or_a = Rufus::Tokyo.h_or_a_to_s(h_or_a)

      m = Rufus::Tokyo::Map[h_or_a]

      r = lib.tab_put(@db, pk, Rufus::Tokyo.blen(pk), m.pointer)

      m.free

      r || raise_error # raising potential error after freeing map

      h_or_a
    end

    # Removes an entry in the table
    #
    # (might raise an error if the delete itself failed, but returns nil
    # if there was no entry for the given key)
    #
    def delete (k)

      k = k.to_s

      v = self[k]
      return nil unless v
      libcall(:tab_out, k, Rufus::Tokyo.blen(k))

      v
    end

    # Removes all records in this table database
    #
    def clear

      libcall(:tab_vanish)
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
    #   :native --> returns an instance of Rufus::Tokyo::List instead of
    #     a Ruby Hash, you have to call #free on that List when done with it !
    #     Else you're exposing yourself to a memory leak.
    #
    def keys (options={})

      pre = options.fetch(:prefix, "")

      l = lib.tab_fwmkeys(
        @db, pre, Rufus::Tokyo.blen(pre), options[:limit] || -1)

      l = Rufus::Tokyo::List.new(l)

      options[:native] ? l : l.release
    end

    # Deletes all the entries whose key begin with the given prefix.
    #
    def delete_keys_with_prefix (prefix)

      query_delete { |q| q.add('', :strbw, prefix) }
    end

    # No 'misc' methods for the table library, so this lget is equivalent
    # to calling get for each key. Hoping later versions of TC will provide
    # a mget method.
    #
    def lget (*keys)

      keys.flatten.inject({}) { |h, k|
        k = k.to_s
        v = self[k]
        h[k] = v if v
        h
      }
    end

    alias :mget :lget

    # Returns the number of records in this table db
    #
    def size

      lib.tab_rnum(@db)
    end

    # Prepares a query instance (block is optional)
    #
    def prepare_query (&block)

      q = TableQuery.new(self)
      block.call(q) if block

      q
    end

    # Prepares and runs a query, returns a ResultSet instance
    # (takes care of freeing the query structure)
    #
    def do_query (&block)

      q = prepare_query(&block)
      rs = q.run

      return rs

    ensure
      q && q.free
    end

    # Prepares and runs a query, returns an array of hashes (all Ruby)
    # (takes care of freeing the query and the result set structures)
    #
    def query (&block)

      rs = do_query(&block)
      a = rs.to_a

      return a

    ensure
      rs && rs.free
    end

    # Prepares a query and then runs it and deletes all the results.
    #
    def query_delete (&block)

      q = prepare_query(&block)
      rs = q.delete

      return rs

    ensure
      q && q.free
    end

    # Prepares a query and then runs it and deletes all the results.
    #
    def query_count (&block)

      q = prepare_query { |q|
        q.pk_only  # improve efficiency, since we have to do the query
      }
      q.count
    ensure
      q.free if q
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction begin'.
    #
    def tranbegin

      libcall(:tctdbtranbegin)
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction commit'.
    #
    def trancommit

      libcall(:tctdbtrancommit)
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction abort'.
    #
    def tranabort

      libcall(:tctdbtranabort)
    end

    # Returns the actual pointer to the Tokyo Cabinet table
    #
    def pointer

      @db
    end

    # Returns the union of the listed queries
    #
    #   r = table.union(
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'es'
    #     },
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'li'
    #     }
    #   )
    #
    # will return a hash { primary_key => record } of the values matching
    # the first query OR the second.
    #
    # If the last element element passed to this method is the value 'false',
    # the return value will the array of matching primary keys.
    #
    def union (*queries)

      search(:union, *queries)
    end

    # Returns the intersection of the listed queries
    #
    #   r = table.intersection(
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'es'
    #     },
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'li'
    #     }
    #   )
    #
    # will return a hash { primary_key => record } of the values matching
    # the first query AND the second.
    #
    # If the last element element passed to this method is the value 'false',
    # the return value will the array of matching primary keys.
    #
    def intersection (*queries)

      search(:intersection, *queries)
    end

    # Returns the difference of the listed queries
    #
    #   r = table.intersection(
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'es'
    #     },
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'li'
    #     }
    #   )
    #
    # will return a hash { primary_key => record } of the values matching
    # the first query OR the second but not both.
    #
    # If the last element element passed to this method is the value 'false',
    # the return value will the array of matching primary keys.
    #
    def difference (*queries)

      search(:difference, *queries)
    end

    # A #search a la ruby-tokyotyrant
    # (http://github.com/actsasflinn/ruby-tokyotyrant/tree)
    #
    #   r = table.search(
    #     :intersection,
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'es'
    #     },
    #     @t.prepare_query { |q|
    #       q.add 'lang', :includes, 'li'
    #     }
    #   )
    #
    # Accepts the symbols :union, :intersection, :difference or :diff as
    # first parameter.
    #
    # If the last element element passed to this method is the value 'false',
    # the return value will the array of matching primary keys.
    #
    def search (type, *queries)

      run_query = true
      run_query = queries.pop if queries.last == false

      raise(
        ArgumentError.new("pass at least one prepared query")
      ) if queries.size < 1

      raise(
        ArgumentError.new("pass instances of Rufus::Tokyo::TableQuery only")
      ) if queries.find { |q| q.class != TableQuery }

      t = META_TYPES[type]

      raise(
        ArgumentError.new("no search type #{type.inspect}")
      ) unless t

      qs = FFI::MemoryPointer.new(:pointer, queries.size)
      qs.write_array_of_pointer(queries.collect { |q| q.pointer })

      r = lib.tab_metasearch(qs, queries.size, t)

      qs.free

      pks = Rufus::Tokyo::List.new(r).release

      run_query ? lget(pks) : pks
    end

    protected

    META_TYPES = {
      :union => 0, :intersection => 1, :difference => 2, :diff => 2
    }

    # Returns the value (as a Ruby Hash) else nil
    #
    # (the actual #[] method is provided by HashMethods)
    #
    def get (k)
      k = k.to_s
      m = lib.tab_get(@db, k, Rufus::Tokyo.blen(k))

      return nil if m.address == 0

      Map.to_h(m) # which frees the map
    end

    def libcall (lib_method, *args)

      lib.send(lib_method, @db, *args) || raise_error
        # stack level too deep with JRuby 1.1.6 :(

      #(eval(%{ lib.#{lib_method}(@db, *args) }) == 1) or raise_error
        # works with JRuby 1.1.6
    end

    # Obviously something got wrong, let's ask the db about it and raise
    # a TokyoError
    #
    def raise_error

      err_code = lib.tab_ecode(@db)
      err_msg = lib.tab_errmsg(err_code)

      raise TokyoError.new("(err #{err_code}) #{err_msg}")
    end
  end

  #
  # A query on a Tokyo Cabinet table db
  #
  class TableQuery

    include QueryConstants

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
    def initialize (table)

      @table   = table
      @query   = @table.lib.qry_new(@table.pointer)
      @opts    = {}
      @has_run = false
    end

    # Returns the FFI lib the table uses.
    #
    def lib

      @table.lib
    end

    # Returns the underlying pointer.
    #
    def pointer

      @query
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
    #   :ftsph # full-text phrase search
    #   :ftsphrase
    #   :phrase
    #   :ftsand # full-text AND
    #   :ftsor # full-text OR
    #   :ftsex # full-text with 'compound' expression
    #
    def add (colname, operator, val, affirmative=true, no_index=false)

      colname = colname.to_s
      val = val.to_s

      op = operator.is_a?(Fixnum) ? operator : OPERATORS[operator]
      op = op | TDBQCNEGATE unless affirmative
      op = op | TDBQCNOIDX if no_index
      lib.qry_addcond(@query, colname, op, val)
    end
    alias :add_condition :add

    # Sets the max number of records to return for this query.
    #
    # (If you're using TC >= 1.4.10 the optional 'offset' (skip) parameter
    # is accepted)
    #
    def limit (i, offset=-1)

      lib.qry_setlimit(@query, i, offset)
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

      lib.qry_setorder(@query, colname.to_s, DIRECTIONS[direction])
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

    # Process each record using the supplied block, which will be passed
    # two parameters, the primary key and the value hash.
    #
    # The block passed to this method accepts two parameters : the [String]
    # primary key and a Hash of the values for the record.
    #
    # The return value of the passed block does matter. Three different
    # values are expected :stop, :delete or a Hash instance.
    #
    # :stop will make the iteration stop, further matching records will not
    # be passed to the block
    #
    # :delete will let Tokyo Cabinet delete the record just seen.
    #
    # a Hash is passed to let TC update the values for the record just seen.
    #
    # Passing an array is possible : [ :stop, { 'name' => 'Toto' } ] will
    # update the record just seen to a unique column 'name' and will stop the
    # iteration. Likewise, returning [ :stop, :delete ] will work as well.
    #
    # (by Matthew King)
    #
    def process (&block)

      callback = lambda do |pk, pklen, map, opt_param|

        key = pk.read_string(pklen)
        val = Rufus::Tokyo::Map.new(map).to_h

        r = block.call(key, val)
        r = [ r ] unless r.is_a?(Array)

        if updated_value = r.find { |e| e.is_a?(Hash) }
          Rufus::Tokyo::Map.new(map).merge!(updated_value)
        end

        r.inject(0) { |i, v|
          case v
          when :stop then i = i | 1 << 24
          when :delete then i = i | 2
          when Hash then i = i | 1
          end
          i
        }
      end

      lib.qry_proc(@query, callback, nil)

      self
    end

    # Runs this query (returns a TableResultSet instance)
    #
    def run

      @has_run = true
      #@last_resultset =
      TableResultSet.new(@table, lib.qry_search(@query), @opts)
    end

    # Runs this query AND let all the matching records get deleted.
    #
    def delete

      lib.qry_searchout(@query) || raise_error
    end

    # Gets the count of records returned by this query.
    #
    # Note : the 'real' impl is only available since TokyoCabinet 1.4.12.
    #
    def count

      #if lib.respond_to?(:qry_count)
      run.free unless @has_run
      lib.qry_count(@query)
      #else
      #  @last_resultset ? @last_resultset.size : 0
      #end
    end

    # Frees this data structure
    #
    def free

      lib.qry_del(@query)
      @query = nil
    end

    alias :close :free
    alias :destroy :free
  end

  #
  # The thing queries return
  #
  class TableResultSet

    include Enumerable

    def initialize (table, list_pointer, query_opts)

      @table = table
      @list = Rufus::Tokyo::List.new(list_pointer)
      @opts = query_opts
    end

    # Returns the count of element in this result set
    #
    def size

      @list.size
    end

    alias :length :size

    # The classical each
    #
    def each

      (0..size-1).each do |i|
        pk = @list[i]
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

      collect { |m| m }
    end

    # Frees this query (the underlying Tokyo Cabinet list structure)
    #
    def free

      @list.free
      @list = nil
    end
    alias :close :free
    alias :destroy :free

  end
end

