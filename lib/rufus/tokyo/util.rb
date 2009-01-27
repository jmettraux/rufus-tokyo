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

require 'rufus/tokyo/hmethods'
require 'rufus/tokyo/cabinet_lib'


module Rufus::Tokyo

  #
  # A Tokyo Cabinet in-memory (tcutil.h) map
  #
  class Map
    include HashMethods
    include Enumerable

    def self.lib
      Rufus::Tokyo::CabinetLib
    end
    def lib
      self.class.lib
    end

    #
    # Creates an empty instance of a Tokyo Cabinet in-memory map
    #
    # (It's OK to pass the pointer of a C map directly, this is in fact
    # used in rufus/tokyo/table when retrieving entries)
    #
    def initialize (pointer = nil)
      @map = pointer || lib.tcmapnew
    end

    #
    # Inserts key/value pair
    #
    def []= (k, v)
      lib.tcmapput2(m, k, v)
      v
    end

    #
    # Deletes an entry
    #
    def delete (k)
      v = self[k]
      return nil unless v
      (lib.tcmapout2(m, k) == 1) || raise("failed to remove key '#{k}'")
      v
    end

    #
    # Empties the map
    #
    def clear
      lib.tcmapclear(m)
    end

    #
    # Returns the value bound for the key k or nil else.
    #
    def [] (k)
      m; lib.tcmapget2(m, k) rescue nil
    end

    #
    # Returns an array of all the keys in the map
    #
    def keys
      a = []
      lib.tcmapiterinit(m)
      while (k = (lib.tcmapiternext2(m) rescue nil)); a << k; end
      a
    end

    #
    # Returns the count of entries in the map
    #
    def size
      lib.tcmaprnum(m)
    end

    alias :length :size

    #
    # Frees the map (nukes it from memory)
    #
    def free
      lib.tcmapdel(@map)
      @map = nil
    end

    alias :destroy :free

    #
    # Returns the pointer to the underlying Tokyo Cabinet map
    #
    def pointer
      @map || raise('map got freed, cannot use anymore')
    end

    alias :m :pointer

    #
    # Turns a given Tokyo map structure into a Ruby Hash. By default
    # (free = true) will dispose of the map before replying with the Ruby Hash.
    #
    def self.to_h (map_pointer, free = true)
      m = self.new(map_pointer)
      h = m.to_h
      m.free if free
      h
    end
  end
end

