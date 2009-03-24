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

    paths = Array(ENV['TOKYO_TYRANT_LIB'] || %w{
      /usr/lib/libtokyotyrant.so
      /opt/local/lib/libtokyotyrant.dylib
      /opt/local/lib/libtokyotyrant.so
      /usr/local/lib/libtokyotyrant.dylib
      /usr/local/lib/libtokyotyrant.so
    })

    path = paths.find { |path| File.exist?(path) }

    raise "Did not find Tokyo Tyrant libraries on your system" unless path

    ffi_lib(path)

    class << self
      alias :attfunc :attach_function
    end

    #
    # tcrdb functions

    attfunc :tcrdbnew, [], :pointer

    attfunc :tcrdbstat, [ :pointer ], :string

    attfunc :tcrdbopen, [ :pointer, :string, :int ], :int
    attfunc :abs_close, :tcrdbclose, [ :pointer ], :int

    attfunc :abs_del, :tcrdbdel, [ :pointer ], :void

    attfunc :abs_rnum, :tcrdbrnum, [ :pointer ], :uint64
    attfunc :abs_size, :tcrdbsize, [ :pointer ], :uint64

    attfunc :abs_put2, :tcrdbput2, [ :pointer, :string, :string ], :int
    attfunc :abs_get2, :tcrdbget2, [ :pointer, :string ], :string
    attfunc :abs_out2, :tcrdbout2, [ :pointer, :string ], :int

    attfunc :abs_iterinit, :tcrdbiterinit, [ :pointer ], :int
    attfunc :abs_iternext2, :tcrdbiternext2, [ :pointer ], :string

    attfunc :abs_vanish, :tcrdbvanish, [ :pointer ], :int

    attfunc :abs_sync, :tcrdbsync, [ :pointer ], :int
    attfunc :abs_copy, :tcrdbcopy, [ :pointer, :string ], :int

    attfunc :abs_fwmkeys2, :tcrdbfwmkeys2, [ :pointer, :string, :int ], :pointer
    attfunc :tcrdbmisc, [ :pointer, :string, :int, :pointer ], :pointer

    #
    # table functions

    attfunc :tab_close, :tcrdbclose, [ :pointer ], :int

    attfunc :tab_genuid, :tcrdbtblgenuid, [ :pointer ], :int64

    attfunc :tab_get, :tcrdbtblget, [ :pointer, :string, :int ], :pointer

    attfunc :tab_iterinit, :tcrdbiterinit, [ :pointer ], :int
    attfunc :tab_iternext2, :tcrdbiternext2, [ :pointer ], :string

    attfunc :tab_put, :tcrdbtblput, [ :pointer, :string, :int, :pointer ], :int

    attfunc :tab_out, :tcrdbtblout, [ :pointer, :string, :int ], :int

    attfunc :tab_ecode, :tcrdbecode, [ :pointer ], :int
    attfunc :tab_errmsg, :tcrdberrmsg, [ :int ], :string

    attfunc :tab_del, :tcrdbdel, [ :pointer ], :void

    attfunc :tab_rnum, :tcrdbrnum, [ :pointer ], :uint64

    attfunc :tab_vanish, :tcrdbvanish, [ :pointer ], :int

    attfunc :tab_setindex, :tcrdbtblsetindex, [ :pointer, :string, :int ], :int

    attfunc :tab_fwmkeys2, :tcrdbfwmkeys2, [ :pointer, :string, :int ], :pointer

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
  end
end
