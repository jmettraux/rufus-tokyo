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

  module Func
    extend FFI::Library

    #ffi_lib '../tokyo-cabinet/libtokyocabinet.dylib'
    ffi_lib '/usr/local/lib/libtokyocabinet.so'

    attach_function :tcadbnew, [], :pointer

    attach_function :tcadbopen, [ :pointer, :string ], :int
    attach_function :tcadbclose, [ :pointer ], :int

    attach_function :tcadbput2, [ :pointer, :string, :string ], :int
    attach_function :tcadbget2, [ :pointer, :string ], :string

    attach_function :tcadbiterinit, [ :pointer ], :int
    attach_function :tcadbiternext2, [ :pointer ], :string

    def self.method_missing (m, *args)
      mm = "tcadb#{m}"
      self.respond_to?(mm) ? self.send(mm, *args) : super
    end
  end

  class Cabinet
    include Enumerable

    def initialize (name)

      @db = Rufus::Tokyo::Func.new

      name = '*' if name == :hash # in memory hash database
      name = '+' if name == :tree # in memory B+ tree database

      Rufus::Tokyo::Func.open(@db, name)
    end

    def []= (k, v)
      Rufus::Tokyo::Func.put2(@db, k, v)
    end

    def [] (k)
      Rufus::Tokyo::Func.get2(@db, k) rescue nil
    end

    def close
      Rufus::Tokyo::Func.close(@db)
    end

    def each
      Rufus::Tokyo::Func.iterinit(@db) # conccurent access ??
      while (k = (Rufus::Tokyo::Func.iternext2(@db) rescue nil))
        yield(k, self[k])
      end
    end
  end
end
end

# db = Rufus::Tokyo::Cabinet.new('data.tch')
#
# #db['nada'] = 'surf'
# #p db['nada']
# #p db['lost']
#
# #500_000.times { |i| db[i.to_s] = "x" }
# #puts :insert_done
#
# p db.inject { |r, (k, v)| k }
#
# db.close

