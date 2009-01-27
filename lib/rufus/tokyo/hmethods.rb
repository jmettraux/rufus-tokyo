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
  # A Tokyo Cabinet in-memory (tcutil.h) map
  #
  module HashMethods

    #
    # Returns an array of all the values in the map
    #
    def values
      collect { |k, v| v }
    end

    #
    # Our classical 'each'
    #
    def each
      keys.each { |k| yield(k, self[k]) }
    end

    #
    # Turns this Tokyo Cabinet map into a Ruby hash
    #
    def to_h
      self.inject({}) { |h, (k, v)| h[k] = v; h }
    end

    #
    # Returns a new Ruby hash which is a merge of this Map and the given hash
    #
    def merge (h)
      self.to_h.merge(h)
    end

    #
    # Merges the entries in the given hash into this map
    #
    def merge! (h)
      h.each { |k, v| self[k] = v }
      self
    end

    # including some methods to the target classes
    #
    def self.included (target)

      target.class_eval do

        #
        # Turns a Ruby hash into a Tokyo Cabinet Map and returns it
        #
        def self.from_h (h)
          h.inject(Map.new) { |m, (k, v)| m[k] = v; m }
        end
      end
    end
  end

end
end

