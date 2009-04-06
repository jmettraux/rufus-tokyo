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
  # The libtokyodystopia.so methods get bound to this module
  #
  module DystopiaLib #:nodoc#

    extend FFI::Library

    #
    # find Tokyo Dystopia lib

    paths = Array(ENV['TOKYO_DYSTOPIA_LIB'] || %w{
      /opt/local/lib/libtokyodystopia.dylib
      /usr/local/lib/libtokyodystopia.dylib
      /usr/local/lib/libtokyodystopia.so
    })

    if path = paths.find { |path| File.exist?(path) }

    raise "did not find Tokyo Dystopia libs on your system" unless path

    ffi_lib(path)

    #
    # tcwdb functions
    #
    # http://tokyocabinet.sourceforge.net/dystopiadoc/#tcwdbapi

    attach_function :tcwdbnew, [], :pointer

    attach_function :tcwdbopen, [ :pointer, :string, :int ], :int
    attach_function :tcwdbclose, [ :pointer ], :int

    attach_function :tcwdbecode, [ :pointer ], :int

    attach_function :tcwdbput2, [ :pointer, :int64, :string, :string ], :pointer
  end
end

