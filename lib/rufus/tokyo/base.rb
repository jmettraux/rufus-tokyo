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

unless defined?(FFI)
  require 'rubygems'
  require 'ffi'
end

module Rufus
module Tokyo

  VERSION = '0.1.3'

  module TokyoMixin

    #
    # The path to the lib in use
    #
    # (returns something like '/usr/local/lib/libtokyodystopia.dylib')
    #
    attr_accessor :lib

    #
    # Given a list of paths, link to the first one available (via #ffi_lib)
    #
    def ffi_paths (paths)

      paths.each do |path|
        if File.exist?(path)
          ffi_lib(path)
          @lib = path
          break
        end
      end
    end

    #
    # Given a short function name, attaches the full function name to that
    # short name
    #
    # (beware names like 'new' and 'open')
    #
    def attach_func (short_name, params, ret)

      long_name = "#{api_name}#{short_name}"
      attach_function(short_name, long_name, params, ret)
    end

    #
    # Returns the api name (downcased), something like 'tcadb' or 'tcwdb'
    #
    def api_name

      ancestors.first.name.split('::').last.downcase
    end
  end
end
end

