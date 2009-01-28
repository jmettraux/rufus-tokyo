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

  module CabinetLibMixin #:nodoc#
    def self.included (target)
      target.class_eval do
        def self.lib
          Rufus::Tokyo::CabinetLib
        end
        def lib
          self.class.lib
        end
      end
    end
  end

  module CabinetLib #:nodoc#
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

    #
    # maybe put that in a standalone c_lib.rb

    # length of a string
    #
    attach_function :strlen, [ :string ], :int

    # frees a mem zone (TC style)
    #
    attach_function :tcfree, [ :pointer ], :void

    #
    # tcadb functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi

    attach_function :tcadbnew, [], :pointer

    attach_function :tcadbopen, [ :pointer, :string ], :int
    attach_function :tcadbclose, [ :pointer ], :int

    attach_function :tcadbdel, [ :pointer ], :void

    attach_function :tcadbrnum, [ :pointer ], :uint64
    attach_function :tcadbsize, [ :pointer ], :uint64

    attach_function :tcadbput2, [ :pointer, :string, :string ], :int
    attach_function :tcadbget2, [ :pointer, :string ], :string
    attach_function :tcadbout2, [ :pointer, :string ], :int

    attach_function :tcadbiterinit, [ :pointer ], :int
    attach_function :tcadbiternext2, [ :pointer ], :string

    attach_function :tcadbvanish, [ :pointer ], :int

    attach_function :tcadbsync, [ :pointer ], :int
    attach_function :tcadbcopy, [ :pointer, :string ], :int

    #
    # tctdb functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attach_function :tctdbnew, [], :pointer

    attach_function :tctdbopen, [ :pointer, :string, :int ], :int

    attach_function :tctdbgenuid, [ :pointer ], :int64

    attach_function :tctdbget, [ :pointer, :string, :int ], :pointer

    attach_function :tctdbput, [ :pointer, :string, :int, :pointer ], :int
    attach_function :tctdbput3, [ :pointer, :string, :string ], :int
    attach_function :tctdbout2, [ :pointer, :string ], :int

    attach_function :tctdbecode, [ :pointer ], :int
    attach_function :tctdberrmsg, [ :int ], :string

    attach_function :tctdbclose, [ :pointer ], :int
    attach_function :tctdbdel, [ :pointer ], :void

    attach_function :tctdbrnum, [ :pointer ], :uint64

    attach_function :tctdbvanish, [ :pointer ], :int

    #
    # tctdbqry functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attach_function :tctdbqrynew, [ :pointer ], :pointer

    attach_function :tctdbqryaddcond, [ :pointer, :string, :int, :string ], :void
    attach_function :tctdbqrysearch, [ :pointer ], :pointer

    attach_function :tctdbqrydel, [ :pointer ], :void

    #
    # tcmap functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attach_function :tcmapnew, [], :pointer

    attach_function :tcmapput2, [ :pointer, :string, :string ], :void
    attach_function :tcmapout2, [ :pointer, :string ], :int
    attach_function :tcmapclear, [ :pointer ], :void

    attach_function :tcmapdel, [ :pointer ], :void

    attach_function :tcmapget2, [ :pointer, :string ], :string

    attach_function :tcmapiterinit, [ :pointer ], :void
    attach_function :tcmapiternext2, [ :pointer ], :string

    attach_function :tcmaprnum, [ :pointer ], :uint64

    #
    # tclist functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attach_function :tclistnew, [], :pointer

    attach_function :tclistnum, [ :pointer ], :int
    attach_function :tclistval2, [ :pointer, :int ], :string

    attach_function :tclistpush2, [ :pointer, :string ], :void
    attach_function :tclistpop2, [ :pointer ], :string
    attach_function :tclistshift2, [ :pointer ], :string
    attach_function :tclistunshift2, [ :pointer, :string ], :void
    attach_function :tclistover2, [ :pointer, :int, :string ], :void

    attach_function :tclistremove2, [ :pointer, :int ], :string
      # beware, seems like have to free the return string self

    attach_function :tclistdel, [ :pointer ], :void
  end
end

