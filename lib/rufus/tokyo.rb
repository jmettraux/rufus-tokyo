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

require 'rubygems'
require 'ffi'

module Rufus
module Tokyo

  VERSION = '0.1.0'

  module Func
    extend FFI::Library

    #
    # find Tokyo Cabinet lib

    paths = Array(ENV['TOKYO_CABINET_LIB'] || %w{
      /opt/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.so
    })

    paths.each do |path|
      if File.exist?(path)
        ffi_lib(path)
        @lib = path
        break
      end
    end

    attach_function :tcadbnew, [], :pointer

    attach_function :tcadbopen, [ :pointer, :string ], :int
    attach_function :tcadbclose, [ :pointer ], :int

    attach_function :tcadbrnum, [ :pointer ], :uint64
    attach_function :tcadbsize, [ :pointer ], :uint64

    attach_function :tcadbput2, [ :pointer, :string, :string ], :int
    attach_function :tcadbget2, [ :pointer, :string ], :string
    attach_function :tcadbout2, [ :pointer, :string ], :int

    attach_function :tcadbiterinit, [ :pointer ], :int
    attach_function :tcadbiternext2, [ :pointer ], :string

    def self.method_missing (m, *args)
      mm = "tcadb#{m}"
      self.respond_to?(mm) ? self.send(mm, *args) : super
    end
  end

  #
  # Returns the path to the Tokyo Cabinet dynamic library currently in use
  #
  def self.lib
    Rufus::Tokyo::Func.instance_variable_get(:@lib)
  end

  #
  # http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi
  #
  class Cabinet
    include Enumerable

    #
    # Creates/opens the cabinet, raises an exception in case of
    # creation/opening failure.
    #
    def initialize (name)

      @db = Rufus::Tokyo::Func.new

      name = '*' if name == :hash # in memory hash database
      name = '+' if name == :tree # in memory B+ tree database

      (Rufus::Tokyo::Func.open(@db, name) == 1) ||
        raise("failed to open/create db '#{name}'")
    end

    def []= (k, v)
      Rufus::Tokyo::Func.put2(@db, k, v)
    end

    def [] (k)
      Rufus::Tokyo::Func.get2(@db, k) rescue nil
    end

    #
    # Removes a record from the cabinet, returns the value if successful
    # else nil.
    #
    def delete (k)
      v = self[k]
      (Rufus::Tokyo::Func.out2(@db, k) == 1) ? v : nil
    end

    #
    # Returns the number of records in the 'cabinet'
    #
    def size
      Rufus::Tokyo::Func.rnum(@db)
    end

    #
    # Returns the 'weight' of the db (in bytes)
    #
    def weight
      Rufus::Tokyo::Func.size(@db)
    end

    #
    # Closes the cabinet, returns true in case of success.
    #
    def close
      (Rufus::Tokyo::Func.close(@db) == 1)
    end

    #
    # The classical Ruby each (unlocks the power of the Enumerable mixin)
    #
    def each

      Rufus::Tokyo::Func.iterinit(@db) # concurrent access ??

      while (k = (Rufus::Tokyo::Func.iternext2(@db) rescue nil))
        yield(k, self[k])
      end
    end
  end
end
end

