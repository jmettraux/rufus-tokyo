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


module Rufus::Tokyo

  #
  # The libtokyocabinet.so methods get bound to this module
  #
  module TyrantLib #:nodoc#
    extend FFI::Library

    #
    # find Tokyo Tyrant lib

    paths = Array(ENV['TOKYO_TYRANT_LIB'] || %w{
      /opt/local/lib/libtokyotyrant.dylib
      /usr/local/lib/libtokyotyrant.dylib
      /usr/local/lib/libtokyotyrant.so
    })

    ffi_lib(paths.find { |path| File.exist?(path) })

    class << self
      alias :attfunc :attach_function
    end

    #
    # tcrdb functions

    attfunc :tcrdbnew, [], :pointer

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

    #
    # tctdb functions

    #attach_function :tctdbnew, [], :pointer

    #attach_function :tctdbopen, [ :pointer, :string, :int ], :int

    #attach_function :tctdbgenuid, [ :pointer ], :int64

    #attach_function :tctdbget, [ :pointer, :string, :int ], :pointer

    #attach_function :tctdbiterinit, [ :pointer ], :int
    #attach_function :tctdbiternext2, [ :pointer ], :string

    #attach_function :tctdbput, [ :pointer, :string, :int, :pointer ], :int
    #attach_function :tctdbput3, [ :pointer, :string, :string ], :int
    #attach_function :tctdbout2, [ :pointer, :string ], :int

    #attach_function :tctdbecode, [ :pointer ], :int
    #attach_function :tctdberrmsg, [ :int ], :string

    #attach_function :tctdbclose, [ :pointer ], :int
    #attach_function :tctdbdel, [ :pointer ], :void

    #attach_function :tctdbrnum, [ :pointer ], :uint64

    #attach_function :tctdbvanish, [ :pointer ], :int

    #
    # qry functions

    #attach_function :tctdbqrynew, [ :pointer ], :pointer
    #attach_function :tctdbqrydel, [ :pointer ], :void

    #attach_function :tctdbqryaddcond, [ :pointer, :string, :int, :string ], :void
    #attach_function :tctdbqrysetorder, [ :pointer, :string, :int ], :void
    #attach_function :tctdbqrysetmax, [ :pointer, :int ], :void

    #attach_function :tctdbqrysearch, [ :pointer ], :pointer
  end
end

