#--
# Copyright (c) 2009, Adam Keys, John Mettraux
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

  module Ext

    # Calls a lua embedded function
    # (http://tokyocabinet.sourceforge.net/tyrantdoc/#luaext)
    #
    # Options are :global_locking and :record_locking
    #
    # Returns the return value of the called function.
    #
    # Nil is returned in case of failure.
    #
    def ext (func_name, key='', value='', opts={})

      k = key.to_s
      v = value.to_s

      outlen_op(
        :tcrdbext,
        func_name.to_s,
        compute_ext_opts(opts),
        k, Rufus::Tokyo.blen(k),
        v, Rufus::Tokyo.blen(v))
    end
  end
end
