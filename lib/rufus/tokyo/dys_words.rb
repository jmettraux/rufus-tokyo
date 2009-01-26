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

require File.dirname(__FILE__) + '/base'


module Rufus::Tokyo

  module Tcwdb #:nodoc#

    extend FFI::Library
    extend TokyoMixin

    #
    # find Tokyo Dystopia lib

    ffi_paths(Array(ENV['TOKYO_DYSTOPIA_LIB'] || %w{
      /opt/local/lib/libtokyodystopia.dylib
      /usr/local/lib/libtokyodystopia.dylib
      /usr/local/lib/libtokyodystopia.so
    }))

    attach_function :tcwdbnew, [], :pointer
    #attach_func :new, [], :pointer

    attach_func :open, [ :pointer, :string, :int ], :int
    attach_func :close, [ :pointer ], :int

    attach_func :ecode, [ :pointer ], :int

    attach_func :put2, [ :pointer, :uint64, :string, :string ], :pointer
  end

  class DystopianError < RuntimeError
    def new (error_code)
      super("tokyo dystopia error #{error_code}")
    end
  end

  #
  # Tokyo Dystopia words database.
  #
  # http://tokyocabinet.sourceforge.net/dystopiadoc/
  #
  class DysWords

    #
    # Opens/create a Tokyo Dystopia words database.
    #
    def initialize (path, opts={})

      # tcwdb.h :
      #
      #   enum {                 /* enumeration for open modes */
      #     WDBOREADER = 1 << 0, /* open as a reader */
      #     WDBOWRITER = 1 << 1, /* open as a writer */
      #     WDBOCREAT = 1 << 2,  /* writer creating */
      #     WDBOTRUNC = 1 << 3,  /* writer truncating */
      #     WDBONOLCK = 1 << 4,  /* open without locking */
      #     WDBOLCKNB = 1 << 5   /* lock without blocking */
      #   };

      mode = 0

      @db = Rufus::Tokyo::Tcwdb.tcwdbnew

      (Rufus::Tokyo::Tcwdb.open(@db, path, mode) == 1) && return

      raise_error
    end

    protected

    #
    # Raises a dystopian error (asks the db which one)
    #
    def raise_error
      raise DystopianError.new(Rufus::Tokyo::Tcwdb.ecode(@db))
    end
  end
end

