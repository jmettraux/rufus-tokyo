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
  module TyrantLib #:nodoc#

    extend FFI::Library

    #
    # find Tokyo Tyrant lib

    paths = Array(ENV['TOKYO_TYRANT_LIB'] || Dir['/{opt,usr}/{,local/}lib{,64}/libtokyotyrant.{dylib,so*}'])

    begin

      ffi_lib(*paths)

    rescue LoadError => le
      raise(
        "didn't find Tokyo Tyrant libs on your system. " +
        "Please install Tokyo Tyrant (http://tokyocabinet.sf.net) " +
        "(see also http://openwferu.rubyforge.org/tokyo.html)"
      )
    end


    class << self
      alias :attfunc :attach_function
    end

    # http://1978th.net/tokyotyrant/spex.html#tcrdbapi

    #
    # tcrdb functions

    attfunc :tcrdbnew, [], :pointer

    attfunc :tcrdbstat, [ :pointer ], :string

    attfunc :tcrdbtune, [ :pointer, :double, :int ], :bool

    attfunc :tcrdbopen, [ :pointer, :string, :int ], :bool
    attfunc :abs_close, :tcrdbclose, [ :pointer ], :bool

    attfunc :abs_ecode, :tcrdbecode, [ :pointer ], :int
    attfunc :abs_errmsg, :tcrdberrmsg, [ :pointer, :int ], :string

    attfunc :abs_del, :tcrdbdel, [ :pointer ], :void

    attfunc :abs_rnum, :tcrdbrnum, [ :pointer ], :uint64
    attfunc :abs_size, :tcrdbsize, [ :pointer ], :uint64

    attfunc :abs_get, :tcrdbget, [ :pointer, :pointer, :int, :pointer ], :pointer
    attfunc :abs_put, :tcrdbput, [ :pointer, :pointer, :int, :pointer, :int ], :bool

    attfunc :abs_out, :tcrdbout, [ :pointer, :pointer, :int ], :bool

    attfunc :abs_putkeep, :tcrdbputkeep, [ :pointer, :pointer, :int, :pointer, :int ], :bool
    attfunc :abs_putcat, :tcrdbputcat, [ :pointer, :pointer, :int, :pointer, :int ], :bool

    attfunc :abs_iterinit, :tcrdbiterinit, [ :pointer ], :bool
    attfunc :abs_iternext, :tcrdbiternext, [ :pointer, :pointer ], :pointer

    attfunc :abs_vanish, :tcrdbvanish, [ :pointer ], :bool

    attfunc :abs_sync, :tcrdbsync, [ :pointer ], :bool
    attfunc :abs_copy, :tcrdbcopy, [ :pointer, :string ], :bool

    attfunc :abs_fwmkeys, :tcrdbfwmkeys, [ :pointer, :pointer, :int, :int ], :pointer
    attfunc :tcrdbmisc, [ :pointer, :string, :int, :pointer ], :pointer

    attfunc :tcrdbext, [ :pointer, :string, :int, :pointer, :int, :pointer, :int, :pointer ], :pointer

    attfunc :addint, :tcrdbaddint, [ :pointer, :string, :int, :int ], :int
    attfunc :adddouble, :tcrdbadddouble, [ :pointer, :string, :int, :double ], :double

    #
    # table functions

    attfunc :tab_close, :tcrdbclose, [ :pointer ], :bool

    attfunc :tab_genuid, :tcrdbtblgenuid, [ :pointer ], :int64

    attfunc :tab_get, :tcrdbtblget, [ :pointer, :pointer, :int ], :pointer

    attfunc :tab_iterinit, :tcrdbiterinit, [ :pointer ], :bool
    attfunc :tab_iternext, :tcrdbiternext, [ :pointer, :pointer ], :pointer

    attfunc :tab_put, :tcrdbtblput, [ :pointer, :pointer, :int, :pointer ], :bool

    attfunc :tab_out, :tcrdbtblout, [ :pointer, :string, :int ], :bool

    attfunc :tab_ecode, :tcrdbecode, [ :pointer ], :int
    attfunc :tab_errmsg, :tcrdberrmsg, [ :pointer, :int ], :string

    attfunc :tab_del, :tcrdbdel, [ :pointer ], :void

    attfunc :tab_rnum, :tcrdbrnum, [ :pointer ], :uint64

    attfunc :tab_vanish, :tcrdbvanish, [ :pointer ], :bool

    attfunc :tab_setindex, :tcrdbtblsetindex, [ :pointer, :string, :int ], :bool

    attfunc :tab_fwmkeys, :tcrdbfwmkeys, [ :pointer, :pointer, :int, :int ], :pointer

    attfunc :tab_metasearch, :tcrdbmetasearch, [ :pointer, :int, :int ], :pointer

    #
    # qry functions

    attfunc :qry_new, :tcrdbqrynew, [ :pointer ], :pointer
    attfunc :qry_del, :tcrdbqrydel, [ :pointer ], :void

    attfunc :qry_addcond, :tcrdbqryaddcond, [ :pointer, :string, :int, :string ], :void
    attfunc :qry_setorder, :tcrdbqrysetorder, [ :pointer, :string, :int ], :void

    begin
      attfunc :qry_setmax, :tcrdbqrysetmax, [ :pointer, :int ], :void
    rescue FFI::NotFoundError => nfe
      attfunc :qry_setlimit, :tcrdbqrysetlimit, [ :pointer, :int, :int ], :void
    end

    attfunc :qry_search, :tcrdbqrysearch, [ :pointer ], :pointer
    attfunc :qry_searchout, :tcrdbqrysearchout, [ :pointer ], :bool

    # since TC 1.4.21
    attfunc :qry_count, :tcrdbqrysearchcount, [ :pointer ], :int
  end
end

