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

      #
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
      # == :hash or :tree
      #
      # Setting the name to :hash or :tree simply will create a in-memory hash
      # or tree respectively (see #new_tree and #new_hash).
      #
      # == tuning parameters
      #
      # It's ok to use the optional params hash to pass tuning parameters and
      # options, thus
      #
      #   db = Rufus::Tokyo::Cabinet.new('casket.tch#bnum=100000#opts=ld')
      #
      # and
      #
      #   db = Rufus::Tokyo::Cabinet.new(
      #     'casket.tch', :bnum => 100000, :opts => 'ld')
      #
      # are equivalent.
      #
      # == mode
      #
      # To open a db in read-only mode :
      #
      #   db = Rufus::Tokyo::Cabinet.new('casket.tch#mode=r')
      #   db = Rufus::Tokyo::Cabinet.new('casket.tch', :mode => 'r')
      #
      def initialize (name, params={})

        @db = lib.tcadbnew

        name = '*' if name == :hash # in memory hash database
        name = '+' if name == :tree # in memory B+ tree database

        name = name + params.collect { |k, v| "##{k}=#{v}" }.join('')

        (lib.tcadbopen(@db, name) == 1) ||
          raise("failed to open/create db '#{name}'")

        self.default = params[:default]
        @default_proc ||= params[:default_proc]
      end

      #
      # Returns a new in-memory hash. Accepts the same optional params hash
      # as new().
      #
      def self.new_hash (params={})
        self.new(:hash, params)
      end

      #
      # Returns a new in-memory B+ tree. Accepts the same optional params hash
      # as new().
      #
      def self.new_tree (params={})
        self.new(:tree, params)
      end

      #
      # using the cabinet lib
      #
      def lib
        CabinetLib
      end

      #
      # No comment
      #
      def []= (k, v)
        lib.abs_put2(@db, k, v)
      end

      #
      # (The actual #[] method is provided by HashMethods
      #
      def get (k)
        lib.abs_get2(@db, k) rescue nil
      end
      protected :get

      #
      # Removes a record from the cabinet, returns the value if successful
      # else nil.
      #
      def delete (k)
        v = self[k]
        (lib.abs_out2(@db, k) == 1) ? v : nil
      end

      #
      # Returns the number of records in the 'cabinet'
      #
      def size
        lib.abs_rnum(@db)
      end

      #
      # Removes all the records in the cabinet (use with care)
      #
      # Returns self (like Ruby's Hash does).
      #
      def clear
        lib.abs_vanish(@db)
        self
      end

      #
      # Returns the 'weight' of the db (in bytes)
      #
      def weight
        lib.abs_size(@db)
      end

      #
      # Closes the cabinet (and frees the datastructure allocated for it),
      # returns true in case of success.
      #
      def close
        result = lib.abs_close(@db)
        lib.abs_del(@db)
        (result == 1)
      end

      #
      # Copies the current cabinet to a new file.
      #
      # Returns true if it was successful.
      #
      def copy (target_path)
        (lib.abs_copy(@db, target_path) == 1)
      end

      #
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

      #
      # "synchronize updated contents of an abstract database object with
      # the file and the device"
      #
      def sync
        (lib.abs_sync(@db) == 1)
      end

      #
      # Returns an array with all the keys in the databse
      #
      def keys
        a = []
        lib.abs_iterinit(@db)
        while (k = (lib.abs_iternext2(@db) rescue nil)); a << k; end
        a
      end
    end

  end
end
