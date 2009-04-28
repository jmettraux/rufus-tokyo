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


require 'rufus/tokyo/transactions'


module Rufus::Tokyo

  #
  # A 'cabinet', ie a Tokyo Cabinet [abstract] database.
  #
  # Follows the abstract API described at :
  #
  #   http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi
  #
  # An usage example :
  #
  #   db = Rufus::Tokyo::Cabinet.new('test_data.tch')
  #   db['pillow'] = 'Shonagon'
  #
  #   db.size # => 1
  #   db['pillow'] # => 'Shonagon'
  #
  #   db.delete('pillow') # => 'Shonagon'
  #   db.size # => 0
  #
  #   db.close
  #
  class Cabinet

    include HashMethods
    include Transactions

    # Creates/opens the cabinet, raises an exception in case of
    # creation/opening failure.
    #
    # This method accepts a 'name' parameter and an optional 'params' hash
    # parameter.
    #
    # 'name' follows the syntax described at
    #
    #   http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi
    #
    # under tcadbopen(). For example :
    #
    #   db = Rufus::Tokyo::Cabinet.new('casket.tch#bnum=100000#opts=ld')
    #
    # will open (eventually create) a hash database backed in the file
    # 'casket.tch' with a bucket number of 100000 and the 'large' and
    # 'deflate' options (opts) turned on.
    #
    # Note that there is an #open method similar to File#open for openening
    # a db and closing it when it's no longer needed :
    #
    #   Rufus::Tokyo::Cabinet.new('data.tch') do |db|
    #     db['key'] = value
    #   end
    #
    # == database name
    #
    # From http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi :
    #
    # 'If it is "*", the database will be an on-memory hash database. If it is
    #  "+", the database will be an on-memory tree database. If its suffix is
    #  ".tch", the database will be a hash database. If its suffix is ".tcb",
    #  the database will be a B+ tree database. If its suffix is ".tcf", the
    #  database will be a fixed-length database. If its suffix is ".tct", the
    #  database will be a table database.'
    #
    # You're supposed to give a path to the database file you want to use and
    # Cabinet expects you to give the proper prefix.
    #
    #   db = Rufus::Tokyo::Cabinet.new('data.tch') # hash database
    #   db = Rufus::Tokyo::Cabinet.new('data.tcb') # B+ tree db
    #   db = Rufus::Tokyo::Cabinet.new('data.tcf') # fixed-length db
    #
    # will result with the same file names :
    #
    #   db = Rufus::Tokyo::Cabinet.new('data', :type => :hash) # hash database
    #   db = Rufus::Tokyo::Cabinet.new('data', :type => :btree) # B+ tree db
    #   db = Rufus::Tokyo::Cabinet.new('data', :type => :fixed) # fixed-length db
    #
    # You can open an in-memory hash and an in-memory B+ tree with :
    #
    #   h = Rufus::Tokyo::Cabinet.new(:mem_hash) # or
    #   h = Rufus::Tokyo::Cabinet.new('*')
    #
    #   t = Rufus::Tokyo::Cabinet.new(:mem_tree) # or
    #   t = Rufus::Tokyo::Cabinet.new('+')
    #
    # == parameters
    #
    # There are two ways to pass parameters at the opening of a db :
    #
    #   db = Rufus::Tokyo::Cabinet.new('data.tch#opts=ld#mode=w') # or
    #   db = Rufus::Tokyo::Cabinet.new('data.tch', :opts => 'ld', :mode => 'w')
    #
    # most verbose :
    #
    #   db = Rufus::Tokyo::Cabinet.new(
    #     'data', :type => :hash, :opts => 'ld', :mode => 'w')
    #
    # === mode
    #
    #   * :mode    a set of chars ('r'ead, 'w'rite, 'c'reate, 't'runcate,
    #              'e' non locking, 'f' non blocking lock), default is 'wc'
    #
    # === other parameters
    #
    # 'On-memory hash database supports "bnum", "capnum", and "capsiz".
    #  On-memory tree database supports "capnum" and "capsiz".
    #  Hash database supports "mode", "bnum", "apow", "fpow", "opts",
    #  "rcnum", and "xmsiz".
    #  B+ tree database supports "mode", "lmemb", "nmemb", "bnum", "apow",
    #  "fpow", "opts", "lcnum", "ncnum", and "xmsiz".
    #  Fixed-length database supports "mode", "width", and "limsiz"'
    #
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
    #   * :capnum  specifies the capacity number of records.
    #   * :capsiz  specifies the capacity size of using memory.
    #
    #
    # = NOTE :
    #
    # On reopening a file, Cabinet will tend to stick to the parameters as
    # set when the file was opened. To change that, have a look at the
    # man pages of the various command line tools coming with Tokyo Cabinet.
    #
    def initialize (name, params={})

      @db = lib.tcadbnew

      name = '*' if name == :mem_hash # in memory hash database
      name = '+' if name == :mem_tree # in memory B+ tree database

      if type = params.delete(:type)
        name += { :hash => '.tch', :btree => '.tcb', :fixed => '.tcf' }[type]
      end

      @path = name

      name = name + params.collect { |k, v| "##{k}=#{v}" }.join('')

      (lib.tcadbopen(@db, name) == 1) ||
        raise("failed to open/create db '#{name}'  #{params.inspect}")

      self.default = params[:default]
      @default_proc ||= params[:default_proc]
    end

    # Same args as initialize, but can take a block form that will
    # close the db when done. Similar to File.open
    #
    def self.open (name, params={})
      db = self.new(name, params)
      if block_given?
        yield db
        nil
      else
        db
      end
    ensure
      db.close if block_given? && db
    end

    # Returns a new in-memory hash. Accepts the same optional params hash
    # as new().
    #
    def self.new_hash (params={})

      self.new(:hash, params)
    end

    # Returns a new in-memory B+ tree. Accepts the same optional params hash
    # as new().
    #
    def self.new_tree (params={})

      self.new(:tree, params)
    end

    # Using the cabinet lib
    #
    def lib

      CabinetLib
    end

    # Returns the path to this database.
    #
    def path

      @path
    end

    # No comment
    #
    def []= (k, v)
      lib.abs_put2(@db, k, v)
    end

    # (The actual #[] method is provided by HashMethods
    #
    def get (k)
      lib.abs_get2(@db, k) rescue nil
    end
    protected :get

    # Removes a record from the cabinet, returns the value if successful
    # else nil.
    #
    def delete (k)
      v = self[k]
      (lib.abs_out2(@db, k) == 1) ? v : nil
    end

    # Returns the number of records in the 'cabinet'
    #
    def size
      lib.abs_rnum(@db)
    end

    # Removes all the records in the cabinet (use with care)
    #
    # Returns self (like Ruby's Hash does).
    #
    def clear
      lib.abs_vanish(@db)
      self
    end

    # Returns the 'weight' of the db (in bytes)
    #
    def weight
      lib.abs_size(@db)
    end

    # Closes the cabinet (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close
      result = lib.abs_close(@db)
      lib.abs_del(@db)
      (result == 1)
    end

    # Copies the current cabinet to a new file.
    #
    # Returns true if it was successful.
    #
    def copy (target_path)
      (lib.abs_copy(@db, target_path) == 1)
    end

    # Copies the current cabinet to a new file.
    #
    # Does it by copying each entry afresh to the target file. Spares some
    # space, hence the 'compact' label...
    #
    def compact_copy (target_path)
      @other_db = Cabinet.new(target_path)
      self.each { |k, v| @other_db[k] = v }
      @other_db.close
    end

    # "synchronize updated contents of an abstract database object with
    # the file and the device"
    #
    def sync
      (lib.abs_sync(@db) == 1)
    end

    # Returns an array with all the keys in the databse
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

      if pref = options[:prefix]

        l = lib.abs_fwmkeys2(@db, pref, options[:limit] || -1)
        l = Rufus::Tokyo::List.new(l)
        options[:native] ? l : l.release

      else

        limit = options[:limit] || -1
        limit = nil if limit < 1

        l = options[:native] ? Rufus::Tokyo::List.new : []

        lib.abs_iterinit(@db)

        while (k = (lib.abs_iternext2(@db) rescue nil))
          break if limit and l.size >= limit
          l << k
        end

        l
      end
    end

    # Deletes all the entries whose keys begin with the given prefix
    #
    def delete_keys_with_prefix (prefix)

      call_misc('outlist', lib.abs_fwmkeys2(@db, prefix, -1))
        # -1 for no limits
      nil
    end

    # Given a list of keys, returns a Hash { key => value } of the
    # matching entries (in one sweep).
    #
    def lget (keys)

      Hash[*call_misc('getlist', Rufus::Tokyo::List.new(keys))]
    end

    # Merges the given hash into this Cabinet (or Tyrant) and returns self.
    #
    def merge! (hash)

      call_misc(
        'putlist',
        hash.inject(Rufus::Tokyo::List.new) { |l, (k, v)| l << k; l << v; l })
      self
    end
    alias :lput :merge!

    # Given a list of keys, deletes all the matching entries (in one sweep).
    #
    def ldelete (keys)

      call_misc('outlist', Rufus::Tokyo::List.new(keys))
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction begin'.
    #
    def tranbegin

      check_transaction_support

      libcall(:tcadbtranbegin)
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction commit'.
    #
    def trancommit

      check_transaction_support

      libcall(:tcadbtrancommit)
    end

    # Warning : this method is low-level, you probably only need
    # to use #transaction and a block.
    #
    # Direct call for 'transaction abort'.
    #
    def tranabort

      check_transaction_support

      libcall(:tcadbtranabort)
    end

    protected

    def check_transaction_support

      raise(TokyoError.new(
        "The version of Tokyo Cabinet you're using doesn't support " +
        "transactions for non-table structures. Upgrade to TC >= 1.4.13.")
      ) unless lib.respond_to?(:tcadbtranbegin)
    end

    # Wrapping tcadbmisc or tcrdbmisc
    # (and taking care of freeing the list_pointer)
    #
    def call_misc (function, list_pointer)

      list_pointer = list_pointer.pointer \
        if list_pointer.is_a?(Rufus::Tokyo::List)

      begin
        l = do_call_misc(function, list_pointer)
        raise "function '#{function}' failed" unless l
        Rufus::Tokyo::List.new(l).release
      ensure
        Rufus::Tokyo::List.free(list_pointer)
      end
    end

    # calls the tcadbmisc function
    #
    def do_call_misc (function, list_pointer)

      lib.tcadbmisc(@db, function, list_pointer)
    end

    def libcall (lib_method, *args)

      (eval(%{ lib.#{lib_method}(@db, *args) }) == 1) or \
        raise TokyoError.new("call to #{lib_method} failed")
    end
  end
end

