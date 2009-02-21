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

require 'tokyocabinet'
require 'rufus/tokyo/hmethods'


module Rufus::Edo

  class Cabinet

    include Rufus::Tokyo::HashMethods

    def initialize (name, params={})

      if type = params.delete(:type)
        name += { :hash => '.tch', :btree => '.tcb', :fixed => '.tcf' }[type]
      end

      type = name.split('.').last

      klass = {
        'tch' => TokyoCabinet::HDB,
        'tcb' => TokyoCabinet::BDB,
        'tcf' => TokyoCabinet::FDB
      }[type]

      @db = klass.new

      @db.open(name, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT) ||
        raise_error

      # default

      self.default = params[:default]
      @default_proc ||= params[:default_proc]
    end

    #
    # Same args as initialize, but can take a block form that will
    # close the db when done.  Similar to File.open
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

    #
    # No comment
    #
    def []= (k, v)
      @db.put(k, v) || raise_error
    end

    #
    # (The actual #[] method is provided by HashMethods
    #
    def get (k)
      @db.get(k)
    end
    protected :get

    #
    # Removes a record from the cabinet, returns the value if successful
    # else nil.
    #
    def delete (k)
      v = self[k]
      @db.out(k) ? v : nil
    end

    #
    # Returns the number of records in the 'cabinet'
    #
    def size
      @db.rnum
    end

    #
    # Removes all the records in the cabinet (use with care)
    #
    # Returns self (like Ruby's Hash does).
    #
    def clear
      @db.vanish || raise_error
      self
    end

    #
    # Returns the 'weight' of the db (in bytes)
    #
    def weight
      @db.fsiz
    end

    #
    # Closes the cabinet (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close
      @db.close || raise_error
    end

    #
    # Copies the current cabinet to a new file.
    #
    # Returns true if it was successful.
    #
    def copy (target_path)
      @db.copy(target_path)
    end

    #
    # Copies the current cabinet to a new file.
    #
    # Does it by copying each entry afresh to the target file. Spares some
    # space, hence the 'compact' label...
    #
    def compact_copy (target_path)
      @other_db = self.class.new(target_path)
      self.each { |k, v| @other_db[k] = v }
      @other_db.close
    end

    #
    # "synchronize updated contents of an abstract database object with
    # the file and the device"
    #
    def sync
      @db.sync || raise_error
    end

    def keys (options={})

      if pref = options[:prefix]

        @db.fwmkeys(pref, options[:limit] || -1)

      else

        limit = options[:limit] || -1
        limit = nil if limit < 1

        l = []

        @db.iterinit

        while (k = @db.iternext)
          break if limit and l.size >= limit
          l << k
        end

        l
      end
    end

    #
    # Deletes all the entries whose keys begin with the given prefix
    #
    def delete_keys_with_prefix (prefix)

      #call_misc('outlist', lib.abs_fwmkeys2(@db, prefix, -1))
      #  # -1 for no limits
      #nil
      raise NotImplementedError
    end

    #
    # Given a list of keys, returns a Hash { key => value } of the
    # matching entries (in one sweep).
    #
    def lget (keys)

      #Hash[*call_misc('getlist', Rufus::Tokyo::List.new(keys))]
      raise NotImplementedError
    end

    #def merge! (hash)
    #  call_misc(
    #    'putlist',
    #    hash.inject(Rufus::Tokyo::List.new) { |l, (k, v)| l << k; l << v; l })
    #  self
    #end
    #alias :lput :merge!

    #
    # Given a list of keys, deletes all the matching entries (in one sweep).
    #
    def ldelete (keys)
      #call_misc('outlist', Rufus::Tokyo::List.new(keys))
      raise NotImplementedError
    end

    protected

    def raise_error
      code = @db.ecode
      message = @db.errmsg(code)
      raise EdoError.new("(err #{code}) #{message}")
    end
  end
end

