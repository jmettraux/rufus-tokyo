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


require 'ffi' # sudo gem install ffi


module Rufus
module Tokyo

  VERSION = '0.1.13'

  #
  # A common error class
  #
  class TokyoError < RuntimeError; end

  #
  # Grumpf, this is not elegant...
  #
  INT_MIN = -2147483648

  # Returns 'bytesize' of the string (Ruby 1.9.1 for everyone).
  #
  def self.blen (s)

    s.respond_to?(:bytesize) ? s.bytesize : s.size
  end

end
end

require 'rufus/tokyo/cabinet/lib'
require 'rufus/tokyo/cabinet/util'
require 'rufus/tokyo/cabinet/abstract'
require 'rufus/tokyo/cabinet/table'

