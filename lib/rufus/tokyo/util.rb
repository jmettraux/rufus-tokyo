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

require 'rufus/tokyo/base'


module Rufus::Tokyo

  module Tcutil #:nodoc#

    extend FFI::Library
    extend TokyoApiMixin

    #
    # find Tokyo Cabinet lib

    ffi_paths(Array(ENV['TOKYO_CABINET_LIB'] || %w{
      /opt/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.so
    }))

    attach_function :mapnew, :tcmapnew, [], :pointer

    attach_function :mapput2, :tcmapput2, [ :pointer, :string, :string ], :void
    attach_function :mapout2, :tcmapout2, [ :pointer, :string ], :int
    attach_function :mapclear, :tcmapclear, [ :pointer ], :void

    attach_function :mapdel, :tcmapdel, [ :pointer ], :void

    attach_function :mapget2, :tcmapget2, [ :pointer, :string ], :string

    attach_function :mapiterinit, :tcmapiterinit, [ :pointer ], :void
    attach_function :mapiternext2, :tcmapiternext2, [ :pointer ], :string

    attach_function :maprnum, :tcmaprnum, [ :pointer ], :uint64
  end

  class Map < TokyoContainer

    include Enumerable

    api Rufus::Tokyo::Tcutil


    def initialize ()
      @map = api.mapnew
    end

    def []= (k, v)
      api.mapput2(m, k, v)
      v
    end

    def delete (k)
      v = self[k]
      (api.mapout2(m, k) == 1) || raise("failed to remove key '#{k}'")
      v
    end

    def clear
      api.mapclear(m)
    end

    def [] (k)
      api.mapget2(m, k)
    end

    def keys
      a = []
      api.mapiterinit(m)
      while (k = (api.mapiternext2(m) rescue nil)); a << k; end
      a
    end

    def values
      collect { |k, v| v }
    end

    def each
      keys.each { |k| yield(k, self[k]) }
    end

    def size
      api.maprnum(m)
    end

    alias :length :size

    def free
      api.mapdel(@map)
      @map = nil
    end

    alias :destroy :free

    private

    def m
      @map || raise('map got freed, cannot use anymore')
    end
  end
end

