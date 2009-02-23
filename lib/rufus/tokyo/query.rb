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

module Rufus
module Tokyo

  #
  # Some constants shared by table implementations.
  #
  module QueryConstants

    OPERATORS = {

      # strings...

      :streq => 0, # string equality
      :eq => 0,
      :eql => 0,
      :equals => 0,

      :strinc => 1, # string include
      :inc => 1, # string include
      :includes => 1, # string include

      :strbw => 2, # string begins with
      :bw => 2,
      :starts_with => 2,
      :strew => 3, # string ends with
      :ew => 3,
      :ends_with => 3,

      :strand => 4, # string which include all the tokens in the given exp
      :and => 4,

      :stror => 5, # string which include at least one of the tokens
      :or => 5,

      :stroreq => 6, # string which is equal to at least one token

      :strorrx => 7, # string which matches the given regex
      :regex => 7,
      :matches => 7,

      # numbers...

      :numeq => 8, # equal
      :numequals => 8,
      :numgt => 9, # greater than
      :gt => 9,
      :numge => 10, # greater or equal
      :ge => 10,
      :gte => 10,
      :numlt => 11, # greater or equal
      :lt => 11,
      :numle => 12, # greater or equal
      :le => 12,
      :lte => 12,
      :numbt => 13, # a number between two tokens in the given exp
      :bt => 13,
      :between => 13,

      :numoreq => 14 # number which is equal to at least one token
    }

    TDBQCNEGATE = 1 << 24
    TDBQCNOIDX = 1 << 25

    DIRECTIONS = {
      :strasc => 0,
      :strdesc => 1,
      :asc => 0,
      :desc => 1,
      :numasc => 2,
      :numdesc => 3
    }
  end

end
end

