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


module Rufus::Tokyo

  #
  # The libtokyocabinet.so methods get bound to this module
  #
  module CabinetLib #:nodoc#
    extend FFI::Library

    #
    # find Tokyo Cabinet lib

    paths = Array(ENV['TOKYO_CABINET_LIB'] || %w{
      /usr/lib/libtokyocabinet.so
      /opt/local/lib/libtokyocabinet.dylib
      /opt/local/lib/libtokyocabinet.so
      /usr/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.so
    })

    begin

      ffi_lib(*paths)

    rescue LoadError => le
      raise(
        "didn't find Tokyo Cabinet libs on your system. " +
        "Please install Tokyo Cabinet (http://tokyocabinet.sf.net) " +
        "(see also http://openwferu.rubyforge.org/tokyo.html)"
      )
    end

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

    attfunc :abs_put, :tcadbput, [ :pointer, :pointer, :int, :pointer, :int ], :int

    attfunc :abs_get, :tcadbget, [ :pointer, :pointer, :int, :pointer ], :pointer

    attfunc :abs_out, :tcadbout, [ :pointer, :pointer, :int ], :int

    attfunc :abs_putkeep, :tcadbputkeep, [ :pointer, :pointer, :int, :pointer, :int ], :int

    attfunc :abs_iterinit, :tcadbiterinit, [ :pointer ], :int
    attfunc :abs_iternext, :tcadbiternext, [ :pointer, :pointer ], :pointer

    attfunc :abs_vanish, :tcadbvanish, [ :pointer ], :int

    attfunc :abs_sync, :tcadbsync, [ :pointer ], :int
    attfunc :abs_copy, :tcadbcopy, [ :pointer, :string ], :int

    attfunc :abs_fwmkeys, :tcadbfwmkeys, [ :pointer, :pointer, :int, :int ], :pointer

    attfunc :tcadbmisc, [ :pointer, :string, :pointer ], :pointer

    attfunc :addint, :tcadbaddint, [ :pointer, :string, :int, :int ], :int
    attfunc :adddouble, :tcadbadddouble, [ :pointer, :string, :int, :double ], :double

    begin # since TC 1.4.13
      attfunc :tcadbtranbegin, [ :pointer ], :int
      attfunc :tcadbtrancommit, [ :pointer ], :int
      attfunc :tcadbtranabort, [ :pointer ], :int
    rescue FFI::NotFoundError => nfe
    end

    #
    # tctdb functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attfunc :tctdbnew, [], :pointer
    attfunc :tctdbsetmutex, [ :pointer ], :int
    attfunc :tctdbtune, [ :pointer, :uint64, :uint8, :uint8, :uint8 ], :int
    attfunc :tctdbsetcache, [ :pointer, :uint32, :uint32, :uint32 ], :int
    attfunc :tctdbsetxmsiz, [ :pointer, :uint64 ], :int

    begin # since TC 1.4.21
      attfunc :tctdbsetdfunit, [ :pointer, :uint32 ], :int
    rescue FFI::NotFoundError => nfe
    end

    attfunc :tctdbopen, [ :pointer, :string, :int ], :int

    attfunc :tab_close, :tctdbclose, [ :pointer ], :int

    attfunc :tab_genuid, :tctdbgenuid, [ :pointer ], :int64

    attfunc :tab_get, :tctdbget, [ :pointer, :pointer, :int ], :pointer

    attfunc :tab_iterinit, :tctdbiterinit, [ :pointer ], :int
    attfunc :tab_iternext, :tctdbiternext, [ :pointer, :pointer ], :pointer

    attfunc :tab_put, :tctdbput, [ :pointer, :pointer, :int, :pointer ], :int

    #attfunc :tctdbput3, [ :pointer, :string, :string ], :int
      # not using it anymore, Ruby can turn an array into a hash so easily

    attfunc :tab_out, :tctdbout, [ :pointer, :string, :int ], :int

    attfunc :tab_ecode, :tctdbecode, [ :pointer ], :int
    attfunc :tab_errmsg, :tctdberrmsg, [ :int ], :string

    attfunc :tab_del, :tctdbdel, [ :pointer ], :void

    attfunc :tab_rnum, :tctdbrnum, [ :pointer ], :uint64

    attfunc :tab_vanish, :tctdbvanish, [ :pointer ], :int

    attfunc :tab_setindex, :tctdbsetindex, [ :pointer, :string, :int ], :int

    attfunc :tctdbtranbegin, [ :pointer ], :int
    attfunc :tctdbtrancommit, [ :pointer ], :int
    attfunc :tctdbtranabort, [ :pointer ], :int

    attfunc :tab_fwmkeys, :tctdbfwmkeys, [ :pointer, :pointer, :int, :int ], :pointer

    #
    # tctdbqry functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi

    attfunc :qry_new, :tctdbqrynew, [ :pointer ], :pointer
    attfunc :qry_del, :tctdbqrydel, [ :pointer ], :void

    attfunc :qry_addcond, :tctdbqryaddcond, [ :pointer, :string, :int, :string ], :void
    attfunc :qry_setorder, :tctdbqrysetorder, [ :pointer, :string, :int ], :void

    callback :TDBQRYPROC, [:pointer, :int, :pointer, :pointer], :int
    attfunc :qry_proc, :tctdbqryproc, [ :pointer, :TDBQRYPROC, :pointer], :int


    begin # since TC 1.4.10
      attfunc :qry_setmax, :tctdbqrysetmax, [ :pointer, :int ], :void
    rescue FFI::NotFoundError => nfe
      attfunc :qry_setlimit, :tctdbqrysetlimit, [ :pointer, :int, :int ], :void
    end

    attfunc :qry_search, :tctdbqrysearch, [ :pointer ], :pointer
    attfunc :qry_searchout, :tctdbqrysearchout, [ :pointer ], :int

    begin # since TC 1.4.12
      attfunc :qry_count, :tctdbqrycount, [ :pointer ], :int
    rescue FFI::NotFoundError => nfe
    end

    #
    # tcmap functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attfunc :tcmapnew, [], :pointer
    attfunc :tcmapput, [ :pointer, :pointer, :int, :pointer, :int ], :void
    attfunc :tcmapout, [ :pointer, :pointer, :int ], :int
    attfunc :tcmapclear, [ :pointer ], :void
    attfunc :tcmapdel, [ :pointer ], :void
    attfunc :tcmapget, [ :pointer, :pointer, :int, :pointer ], :pointer
    attfunc :tcmapiterinit, [ :pointer ], :void
    attfunc :tcmapiternext, [ :pointer, :pointer ], :pointer
    attfunc :tcmaprnum, [ :pointer ], :uint64

    #
    # tclist functions
    #
    # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi

    attfunc :tclistnew, [], :pointer
    attfunc :tclistnum, [ :pointer ], :int
    attfunc :tclistval, [ :pointer, :int, :pointer ], :pointer
    attfunc :tclistpush, [ :pointer, :pointer, :int ], :void
    attfunc :tclistpop, [ :pointer, :pointer ], :pointer
    attfunc :tclistshift, [ :pointer, :pointer ], :pointer
    attfunc :tclistunshift, [ :pointer, :pointer, :int ], :void
    attfunc :tclistover, [ :pointer, :int, :pointer, :int ], :void
    attfunc :tclistremove, [ :pointer, :int, :pointer ], :pointer
    attfunc :tclistdel, [ :pointer ], :void
  end

end

