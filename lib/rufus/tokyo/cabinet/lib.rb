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

  #
  # The libtokyocabinet.so methods get bound to this module
  #
  module CabinetLib #:nodoc#
    extend FFI::Library

    #
    # find Tokyo Cabinet lib

    paths = Array(ENV['TOKYO_CABINET_LIB'] || %w{
      /opt/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.so
    })

    ffi_lib(paths.find { |path| File.exist?(path) })

    class << self
      alias :attfunc :attach_function
    end

    #
    # maybe put that in a standalone c_lib.rb

    # length of a string
    #
    attfunc :strlen, [ :string ], :int

    # frees a mem zone (TC style)
    #
    attfunc :tcfree, [ :pointer ], :void

    #
    # tcadb functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcadbapi

    attfunc :tcadbnew, [], :pointer

    attfunc :tcadbopen, [ :pointer, :string ], :int
    attfunc :abs_close, :tcadbclose, [ :pointer ], :int

    attfunc :abs_del, :tcadbdel, [ :pointer ], :void

    attfunc :abs_rnum, :tcadbrnum, [ :pointer ], :uint64
    attfunc :abs_size, :tcadbsize, [ :pointer ], :uint64

    attfunc :abs_put2, :tcadbput2, [ :pointer, :string, :string ], :int
    attfunc :abs_get2, :tcadbget2, [ :pointer, :string ], :string
    attfunc :abs_out2, :tcadbout2, [ :pointer, :string ], :int

    attfunc :abs_iterinit, :tcadbiterinit, [ :pointer ], :int
    attfunc :abs_iternext2, :tcadbiternext2, [ :pointer ], :string

    attfunc :abs_vanish, :tcadbvanish, [ :pointer ], :int

    attfunc :abs_sync, :tcadbsync, [ :pointer ], :int
    attfunc :abs_copy, :tcadbcopy, [ :pointer, :string ], :int

    #
    # tctdb functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attfunc :tctdbnew, [], :pointer

    attfunc :tctdbopen, [ :pointer, :string, :int ], :int

    attfunc :tctdbgenuid, [ :pointer ], :int64

    attfunc :tctdbget, [ :pointer, :string, :int ], :pointer

    attfunc :tctdbiterinit, [ :pointer ], :int
    attfunc :tctdbiternext2, [ :pointer ], :string

    attfunc :tctdbput, [ :pointer, :string, :int, :pointer ], :int
    attfunc :tctdbput3, [ :pointer, :string, :string ], :int
    attfunc :tctdbout2, [ :pointer, :string ], :int

    attfunc :tctdbecode, [ :pointer ], :int
    attfunc :tctdberrmsg, [ :int ], :string

    attfunc :tctdbclose, [ :pointer ], :int
    attfunc :tctdbdel, [ :pointer ], :void

    attfunc :tctdbrnum, [ :pointer ], :uint64

    attfunc :tctdbvanish, [ :pointer ], :int

    #
    # tctdbqry functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attfunc :tctdbqrynew, [ :pointer ], :pointer
    attfunc :tctdbqrydel, [ :pointer ], :void

    attfunc :tctdbqryaddcond, [ :pointer, :string, :int, :string ], :void
    attfunc :tctdbqrysetorder, [ :pointer, :string, :int ], :void
    attfunc :tctdbqrysetmax, [ :pointer, :int ], :void

    attfunc :tctdbqrysearch, [ :pointer ], :pointer

    #
    # tcmap functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attfunc :tcmapnew, [], :pointer

    attfunc :tcmapput2, [ :pointer, :string, :string ], :void
    attfunc :tcmapout2, [ :pointer, :string ], :int
    attfunc :tcmapclear, [ :pointer ], :void

    attfunc :tcmapdel, [ :pointer ], :void

    attfunc :tcmapget2, [ :pointer, :string ], :string

    attfunc :tcmapiterinit, [ :pointer ], :void
    attfunc :tcmapiternext2, [ :pointer ], :string

    attfunc :tcmaprnum, [ :pointer ], :uint64

    #
    # tclist functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attfunc :tclistnew, [], :pointer

    attfunc :tclistnum, [ :pointer ], :int
    attfunc :tclistval2, [ :pointer, :int ], :string

    attfunc :tclistpush2, [ :pointer, :string ], :void
    attfunc :tclistpop2, [ :pointer ], :string
    attfunc :tclistshift2, [ :pointer ], :string
    attfunc :tclistunshift2, [ :pointer, :string ], :void
    attfunc :tclistover2, [ :pointer, :int, :string ], :void

    attfunc :tclistremove2, [ :pointer, :int ], :string
      # beware, seems like have to free the return string self

    attfunc :tclistdel, [ :pointer ], :void
  end
end

