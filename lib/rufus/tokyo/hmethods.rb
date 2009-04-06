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


module Rufus
module Tokyo

  #
  # A mixin for Cabinet and Map, gathers all the hash-like methods
  #
  module HashMethods
    include Enumerable

    #
    # The [] methods
    #
    # (assumes there's an underlying get(k) method)
    #
    def [] (k)
      val = get(k)
      return val unless val.nil?
      return nil unless @default_proc
      @default_proc.call(self, k)
    end

    #
    # Returns an array of all the values
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
    # Turns this instance into a Ruby hash
    #
    def to_h
      self.inject({}) { |h, (k, v)| h[k] = v; h }
    end

    #
    # Turns this instance into an array of [ key, value ]
    #
    def to_a
      self.collect { |e| e }
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

    def default (key=nil)
      val = self[key]
      val.nil? ? @default_proc.call(self, key) : val
    end

    def default= (val)
      @default_proc = lambda { |h, k| val }
    end

    attr_reader :default_proc
  end

end
end

