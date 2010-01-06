#--
# Copyright (c) 2009-2010, John Mettraux, jmettraux@gmail.com
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


require 'rufus/tokyo/hmethods'


module Rufus::Tokyo

  #
  # :nodoc:
  #
  module ListMapMixin

    # A shortcut
    #
    def clib

      CabinetLib
    end

    # Returns the underlying 'native' (FFI) memory pointer
    #
    def pointer

      @pointer
    end

    def pointer_or_raise

      @pointer || raise("#{self.class} got freed, cannot use anymore")
    end

    def outlen_op (method, *args)

      args.unshift(pointer_or_raise)

      outlen = FFI::MemoryPointer.new(:int)
      args << outlen

      out = clib.send(method, *args)

      return nil if out.address == 0

      out.get_bytes(0, outlen.get_int(0))

    ensure

      outlen.free

      #clib.free(out)
        # uncommenting that wreaks havoc
    end
  end

  #
  # A Tokyo Cabinet in-memory (tcutil.h) map
  #
  # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi
  #
  class Map

    include HashMethods
    include ListMapMixin

    # Creates an empty instance of a Tokyo Cabinet in-memory map
    #
    # (It's OK to pass the pointer of a C map directly, this is in fact
    # used in rufus/tokyo/table when retrieving entries)
    #
    def initialize (pointer=nil)

      @pointer = pointer || clib.tcmapnew

      @default_proc = nil
    end

    # Inserts key/value pair
    #
    def []= (k, v)

      clib.tcmapput(pointer, k, Rufus::Tokyo::blen(k), v, Rufus::Tokyo::blen(v))

      v
    end

    # Deletes an entry
    #
    def delete (k)

      v = self[k]
      return nil unless v

      clib.tcmapout(pointer_or_raise, k, Rufus::Tokyo::blen(k)) ||
        raise("failed to remove key '#{k}'")

      v
    end

    # Empties the map
    #
    def clear

      clib.tcmapclear(pointer_or_raise)
    end

    # (the actual #[] method is provided by HashMethods)
    #
    def get (k)

      outlen_op(:tcmapget, k, Rufus::Tokyo.blen(k))
    end
    protected :get

    # Returns an array of all the keys in the map
    #
    def keys

      clib.tcmapiterinit(pointer_or_raise)
      a = []

      klen = FFI::MemoryPointer.new(:int)

      loop do
        k = clib.tcmapiternext(@pointer, klen)
        break if k.address == 0
        a << k.get_bytes(0, klen.get_int(0))
      end

      return a

    ensure

      klen.free
    end

    # Returns the count of entries in the map
    #
    def size

      clib.tcmaprnum(pointer_or_raise)
    end

    alias :length :size

    # Frees the map (nukes it from memory)
    #
    def free

      clib.tcmapdel(pointer_or_raise)
      @pointer = nil
    end

    alias :destroy :free
    alias :close :free

    # Turns a given Tokyo map structure into a Ruby Hash. By default
    # (free = true) will dispose of the map before replying with the Ruby
    # Hash.
    #
    def self.to_h (map_pointer, free=true)

      m = self.new(map_pointer)
      h = m.to_h
      m.free if free

      h
    end

    # Turns a Ruby hash into a Tokyo Cabinet Map and returns it
    # (don't forget to free the map when you're done with it !)
    #
    def self.from_h (h)

      h.inject(Map.new) { |m, (k, v)| m[k] = v; m }
    end

    # Behaves much like Hash#[] but outputs a Rufus::Tokyo::Map
    # (don't forget to free the map when you're done with it !)
    #
    def self.[] (*h_or_a)

      if h_or_a.is_a?(Array) && h_or_a.size == 1 && h_or_a.first.is_a?(Array)
        h_or_a = h_or_a.first
      end

      from_h(::Hash[*h_or_a])
    end
  end

  #
  # A Tokyo Cabinet in-memory (tcutil.h) list
  #
  # http://tokyocabinet.sourceforge.net/spex-en.html#tcutilapi
  #
  class List

    include Enumerable
    include ListMapMixin

    # Creates a new Tokyo Cabinet list.
    #
    # (by passing a list pointer, one can wrap an existing list pointer
    # into a handy instance of this class)
    #
    def initialize (list_pointer=nil)

      if list_pointer.is_a?(FFI::Pointer)
        @pointer = list_pointer
      else
        @pointer = clib.tclistnew
        list_pointer.each { |e| self << e } if list_pointer
      end
    end

    # Inserts an element in the list (note that the lib will raise an
    # ArgumentError if s is not a String)
    #
    def << (s)

      clib.tclistpush(@pointer, s, Rufus::Tokyo.blen(s))

      self
    end

    # Pushes an argument or a list of arguments to this list
    #
    def push (*args)

      args.each { |a| self << a }

      self
    end

    # Pops the last element in the list
    #
    def pop

      outlen_op(:tclistpop)
    end

    # Removes and returns the first element in a list
    #
    def shift

      #clib.tclistshift2(@pointer) rescue nil
      outlen_op(:tclistshift)
    end

    # Inserts a string at the beginning of the list
    #
    def unshift (s)

      clib.tclistunshift(@pointer, s, Rufus::Tokyo.blen(s))

      self
    end

    # The put operation.
    #
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
          clib.tclistover(@pointer, offset, val, Rufus::Tokyo.blen(val))
        else
          outlen_op(:tclistremove, values.size)
        end
      end

      self
    end

    # Removes the value at a given index and returns the value
    # (returns nil if no value available)
    #
    def delete_at (i)

      outlen_op(:tclistremove, i)
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

    # Returns the size of this Tokyo Cabinet list
    #
    def size

      clib.tclistnum(@pointer)
    end

    alias :length :size

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

      r = norm(range).collect { |ii| outlen_op(:tclistval, ii) }

      range.first == range.last ? r.first : r
    end

    # Empties the list.
    #
    def clear

      clib.tclistclear(@pointer)
    end

    # The classical each.
    #
    def each

      (0..self.size - 1).each { |i| yield self[i] }
    end

    # Turns this Tokyo Cabinet list into a Ruby array
    #
    def to_a

      self.collect { |e| e }
    end

    # Closes (frees) this list
    #
    def free

      self.class.free(@pointer)
      @pointer = nil
    end

    alias :close :free
    alias :destroy :free

    # Frees (closes) the given 'native' (FFI) list (memory pointer)
    #
    def self.free (list_pointer)

      CabinetLib.tclistdel(list_pointer)
    end

    # Closes (frees memory from it) this list and returns the ruby version
    # of it
    #
    def release

      a = self.to_a
      self.close
      a
    end

    # Turns a list pointer into a Ruby Array instance (and makes sure to
    # release the pointer
    #
    def self.release (list_pointer)

      Rufus::Tokyo::List.new(list_pointer).release
    end

    protected

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

