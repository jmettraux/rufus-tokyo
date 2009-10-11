#--
# Copyright (c) 2009, Jeremy Hinegardner, jeremy@copiousfreetime.org
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
# Developed with and sponsored by Seven Scale <http://sevenscale.com/>,
# creators of Open Syslog.
#
#++
require 'rufus/tokyo/openable'

module Rufus::Tokyo::Dystopia
  #
  # Tokyo Dystopia Indexed Database
  #
  # http://tokyocabinet.sourceforge.net/dystopiadoc/#dystopiaapi
  #
  class Core
    extend Rufus::Tokyo::Openable
    
    class Error < Rufus::Tokyo::Dystopia::Error; end

    def self.lib
      ::Rufus::Tokyo::DystopiaLib
    end

    def self.mode_to_bits( mode )
      @modes_to_bits ||= {
        "r"  => lib::READER,
        "r+" => lib::READER | lib::WRITER,
        "w"  => lib::WRITER | lib::CREAT | lib::TRUNC,
        "w+" => lib::READER | lib::WRITER | lib::CREAT | lib::TRUNC,
        "a"  => lib::WRITER | lib::CREAT,
        "a+" => lib::READER | lib::WRITER | lib::CREAT ,
      }

      return @modes_to_bits[mode]
    end

    def self.locking_to_bits( locking )
      @locking_to_bits ||= {
        true  => 0,
        false => lib::NOLCK,
        :nonblocking => lib::LCKNB
      }
      return @locking_to_bits[locking]
    end

    def lib
      Core.lib
    end

    #
    # Opens/creates a new Tokyo dystopia database
    #
    # The modes are equivelent to those when opening a file:
    #
    # 'r'  : readonly
    # 'r+' : read/write does not create or truncate
    # 'w'  : write only, create and truncate
    # 'w+' : read/write, create and truncate
    # 'a'  : write only, create if db does not exist
    # 'a+' : read/write, create if db does not exist
    #
    # The third parameter 'locking' can be one of 'true', 'false' or
    # :nonblocking
    #
    def initialize( path, mode = "a+", locking = true )
      mode_bits = Core.mode_to_bits( mode )
      raise Error.new( "Invalid mode '#{mode}'" ) unless mode_bits
      lock_bits = Core.locking_to_bits( locking )
      raise Error.new( "Invalid Locking mode #{locking}" ) unless lock_bits

      @db = lib.tcidbnew()

      rc = lib.tcidbopen( @db, path, mode_bits | lock_bits )
      raise_error unless rc == 1
    end

    #
    # Close and detach from the database.  This instance can not be used anymore
    #
    def close
      rc = lib.tcidbclose( @db )
      raise_error unless rc == 1

      lib.tcidbdel( @db )
      raise_error unless rc == 1

      @db = nil
    end

    #
    # Add a new document to the database
    #
    def store( id, text )
      rc = lib.tcidbput( @db, id, text )
      raise_error unless rc == 1
    end

    #
    # Remove the given document from the index
    #
    def delete( id )
      rc = lib.tcidbout( @db, id )
      raise_error unless rc == 1
    end

    #
    # Return the document at the specified index
    #
    def fetch( id )
      r = nil
      begin
        r = lib.tcidbget( @db, id )
      rescue => e
        # if we have 'no record found' then return nil
        if lib.tcidbecode( @db ) == 22 then
          return nil
        else
          raise_error
        end
      end
      return r
    end

    #
    # Return the document ids of the documents that matche the search expression
    #
    # http://tokyocabinet.sourceforge.net/dystopiadoc/#dystopiaapi and scroll
    # down to 'Compound Expression of Search'
    #
    def search( expression )
      out_count = ::FFI::MemoryPointer.new :pointer
      out_list  = ::FFI::MemoryPointer.new :pointer
      out_list  = lib.tcidbsearch2( @db, expression, out_count )

      count = out_count.read_int
      results = out_list.get_array_of_uint64(0, count )
      return results
    end

    #
    # Remove all records from the db
    #
    def clear
      lib.tcidbvanish( @db )
    end

    #
    # Report the path of the database
    #
    def path
      s = lib.tcidbpath( @db )
      return File.expand_path( s ) if s
    end

    #
    # Return the number of records in the database
    #
    def count
      lib.tcidbrnum( @db )
    end
    alias :rnum :count

    #
    # return the disk space used by the index
    #
    def fsize
      lib.tcidbfsiz( @db )
    end

    protected

    #
    # Raises a dystopian error (asks the db which one)
    #
    def raise_error
      code = lib.tcidbecode( @db )
      msg  = lib.tcidberrmsg( code )
      raise Error.new("[ERROR #{code}] : #{msg}")
    end

  end
end
