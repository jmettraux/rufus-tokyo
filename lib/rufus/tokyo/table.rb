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
  # http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi
  #
  module Tctdb #:nodoc#

    extend FFI::Library
    extend TokyoApiMixin

    #
    # find Tokyo Cabinet lib

    ffi_paths(Array(ENV['TOKYO_CABINET_LIB'] || %w{
      /opt/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.dylib
      /usr/local/lib/libtokyocabinet.so
    }))

    attach_function :tctdbnew, [], :pointer
    #attach_func :new, [], :pointer

    attach_func :open, [ :pointer, :string, :int ], :int

    attach_func :genuid, [ :pointer ], :int64

    attach_func :put3, [ :pointer, :string, :string ], :int

    attach_func :ecode, [ :pointer ], :int
    attach_func :errmsg, [ :int ], :string

    attach_func :close, [ :pointer ], :int
    attach_func :del, [ :pointer ], :void
  end

  #
  # A 'table' a table database.
  #
  #   http://alpha.mixi.co.jp/blog/?p=290
  #   http://tokyocabinet.sourceforge.net/spex-en.html#tctdbapi
  #
  class Table < TokyoContainer

    include TokyoContainerMixin

    api Rufus::Tokyo::Tctdb

    def initialize (*args)

      path = args.first # car
      params = args[1..-1] # cdr

      mode = compute_open_mode(params)

      @db = api.tctdbnew

      (api.open(@db, path, compute_open_mode(params)) == 1 ) || raise_error
    end

    #
    # Closes the table (and frees the datastructure allocated for it),
    # returns true in case of success.
    #
    def close
      result = api.close(@db)
      api.del(@db)
      (result == 1)
    end

    #
    # Generates a unique id (in the context of this Table instance)
    #
    def generate_unique_id

      api.genuid(@db)
    end
    alias :genuid :generate_unique_id

    #
    # Accepts a variable number of arguments, at least two. First one
    # is the primary key of the record, the others are the columns.
    #
    def tabbed_put (*args)

      pkey = args.first
      cols = args[1..-1].collect { |e| e.to_s }.join("\t")

      (api.put3(@db, pkey, cols) == 1) || raise_error
    end

    protected

    #
    # Obviously something got wrong, let's ask the db about it and raise
    # a TokyoError
    #
    def raise_error

      err_code = api.ecode(@db)
      err_msg = api.errmsg(err_code)

      raise TokyoError, "(err #{err_code}) #{err_msg}"
    end
  end
end

