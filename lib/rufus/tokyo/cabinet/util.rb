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
require 'rufus/tokyo/cabinet/lib'


module Rufus::Tokyo

  #
  # A Tokyo Cabinet in-memory (tcutil.h) map
  #
  # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi
  #
  class Map
    include HashMethods

    #
    # Creates an empty instance of a Tokyo Cabinet in-memory map
    #
    # (It's OK to pass the pointer of a C map directly, this is in fact
    # used in rufus/tokyo/table when retrieving entries)
    #
    def initialize (pointer = nil)
      @map = pointer || clib.tcmapnew
    end

    #
    # a shortcut
    #
    def clib
      Rufus::Tokyo::CabinetLib
    end

    #
    # Inserts key/value pair
    #
    def []= (k, v)
      clib.tcmapput2(m, k, v)
      v
    end

    #
    # Deletes an entry
    #
    def delete (k)
      v = self[k]
      return nil unless v
      (clib.tcmapout2(m, k) == 1) || raise("failed to remove key '#{k}'")
      v
    end

    #
    # Empties the map
    #
    def clear
      clib.tcmapclear(m)
    end

    #
    # (the actual #[] method is provided by HashMethods)
    #
    def get (k)
      m; clib.tcmapget2(m, k) rescue nil
    end
    protected :get

    #
    # Returns an array of all the keys in the map
    #
    def keys
      a = []
      clib.tcmapiterinit(m)
      while (k = (clib.tcmapiternext2(m) rescue nil)); a << k; end
      a
    end

    #
    # Returns the count of entries in the map
    #
    def size
      clib.tcmaprnum(m)
    end

    alias :length :size

    #
    # Frees the map (nukes it from memory)
    #
    def free
      clib.tcmapdel(@map)
      @map = nil
    end

    alias :destroy :free
    alias :close :free

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

    #
    # Turns a Ruby hash into a Tokyo Cabinet Map and returns it
    #
    def self.from_h (h)
      h.inject(Map.new) { |m, (k, v)| m[k] = v; m }
    end
  end

  #
  # A Tokyo Cabinet in-memory (tcutil.h) list
  #
  # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi
  #
  class List
    include Enumerable

    #
    # Creates a new Tokyo Cabinet list.
    #
    # (by passing a list pointer, one can wrap an existing list pointer
    # into a handy instance of this class)
    #
    def initialize (list_pointer = nil)
      @list = list_pointer || clib.tclistnew
    end

    def << (s)
      #raise 'cannot insert nils into Tokyo Cabinet lists' unless s
      clib.tclistpush2(@list, s)
      self
    end

    #
    # Pushes an argument or a list of arguments to this list
    #
    def push (*args)
      args.each { |a| self << a }
    end

    #
    # Pops the last element in the list
    #
    def pop
      clib.tclistpop2(@list) rescue nil
    end

    #
    # Removes and returns the first element in a list
    #
    def shift
      clib.tclistshift2(@list) rescue nil
    end

    #
    # Inserts a string at the beginning of the list
    #
    def unshift (s)
      clib.tclistunshift2(@list, s)
      self
    end

    def []= (a, b, c=nil)

      i, s = c.nil? ? [ a, b ] : [ [a, b], c ]

      range = if i.is_a?(Range)
        i
      elsif i.is_a?(Array)
        start, count = i
        (start..start + count - 1)
      else
        [ i ]
      end

      range = norm(range)

      values = s.is_a?(Array) ? s : [ s ]
        # not "values = Array(s)"

      range.each_with_index do |offset, index|
        val = values[index]
        if val
          clib.tclistover2(@list, offset, val)
        else
          clib.tclistremove2(@list, values.size)
        end
      end

      self
    end

    #
    # Removes the value at a given index and returns the value
    # (returns nil if no value available)
    #
    def delete_at (i)
      clib.tclistremove2(@list, i)
    end

    def delete_if
      # TODO
    end

    def slice
      # TODO
    end
    def slice!
      # TODO
    end

    #
    # Returns the size of this Tokyo Cabinet list
    #
    def size
      clib.tclistnum(@list)
    end

    alias :length :size

    #
    # The equivalent of Ruby Array#[]
    #
    def [] (i, count=nil)

      return nil if (count != nil) && count < 1

      len = self.size

      range = if count.nil?
        i.is_a?(Range) ? i : [i]
      else
        (i..i + count - 1)
      end

      r = norm(range).collect { |i| clib.tclistval2(@list, i) rescue nil }

      range.first == range.last ? r.first : r
    end

    def clear
      clib.tclistclear(@list)
    end

    def each
      (0..self.size - 1).each { |i| yield self[i] }
    end

    #
    # Turns this Tokyo Cabinet list into a Ruby array
    #
    def to_a
      self.collect { |e| e }
    end

    #
    # Closes (frees) this list
    #
    def close
      clib.tclistdel(@list)
      @list = nil
    end

    alias :free :close
    alias :destroy :close

    protected

    #
    # Makes sure this offset/range fits the size of the list
    #
    def norm (i)
      l = self.length
      case i
        when Range then ((i.first % l)..(i.last % l))
        when Array then [ i.first % l ]
        else i % l
      end
    end

  end
end

