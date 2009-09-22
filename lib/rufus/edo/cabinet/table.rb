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


require 'tokyocabinet'

require 'rufus/edo/error'
require 'rufus/edo/tabcore'
require 'rufus/tokyo/config'


module Rufus::Edo

  #
  # Rufus::Edo::Table wraps Hirabayashi-san's Ruby bindings for Tokyo Cabinet
  # tables.
  #
  # This class has the exact same methods as Rufus::Tokyo::Table. It's faster
  # though. The advantage of Rufus::Tokyo::Table lies in that in runs on
  # Ruby 1.8, 1.9 and JRuby.
  #
  # You need to have Hirabayashi-san's binding installed to use this
  # Rufus::Edo::Table :
  #
  #   http://github.com/jmettraux/rufus-tokyo/tree/master/lib/rufus/edo
  #
  # Example usage :
  #
  #   require 'rufus/edo'
  #   db = Rufus::Edo::Table.new('data.tct')
  #   db['customer1'] = { 'name' => 'Taira no Kyomori', 'age' => '55' }
  #   # ...
  #   db.close
  #
  class Table

    include Rufus::Tokyo::CabinetConfig
    include Rufus::Edo::TableCore

    # Initializes and open a table.
    #
    # db = Rufus::Edo::Table.new('data.tct')
    #   # or
    # db = Rufus::Edo::Table.new('data', :type => :table)
    #   # or
    # db = Rufus::Edo::Table.new('data')
    #
    # == parameters
    #
    # There are two ways to pass parameters at the opening of a db :
    #
    #   db = Rufus::Edo::Table.new('data.tct#opts=ld#mode=w') # or
    #   db = Rufus::Edo::Table.new('data.tct', :opts => 'ld', :mode => 'w')
    #
    # === mode
    #
    #   * :mode    a set of chars ('r'ead, 'w'rite, 'c'reate, 't'runcate,
    #              'e' non locking, 'f' non blocking lock), default is 'wc'
    #
    # === other parameters
    #
    #   * :opts    a set of chars ('l'arge, 'd'eflate, 'b'zip2, 't'cbs)
    #              (usually empty or something like 'ld' or 'lb')
    #
    #   * :bnum    number of elements of the bucket array
    #   * :apow    size of record alignment by power of 2 (defaults to 4)
    #   * :fpow    maximum number of elements of the free block pool by
    #              power of 2 (defaults to 10)
    #
    #   * :rcnum   specifies the maximum number of records to be cached.
    #              If it is not more than 0, the record cache is disabled.
    #              It is disabled by default.
    #   * :lcnum   specifies the maximum number of leaf nodes to be cached.
    #              If it is not more than 0, the default value is specified.
    #              The default value is 2048.
    #   * :ncnum   specifies the maximum number of non-leaf nodes to be
    #              cached. If it is not more than 0, the default value is
    #              specified. The default value is 512.
    #
    #   * :dfunit  unit step number. If it is not more than 0,
    #              the auto defragmentation is disabled. (Since TC 1.4.21)
    #
    # = NOTE :
    #
    # On reopening a file, Cabinet will tend to stick to the parameters as
    # set when the file was opened. To change that, have a look at the
    # man pages of the various command line tools coming with Tokyo Cabinet.
    #
    def initialize (path, params={})

      conf = determine_conf(path, params, :table)

      @db = TokyoCabinet::TDB.new

      #
      # tune

      @db.tune(conf[:bnum], conf[:apow], conf[:fpow], conf[:opts])

      #
      # set cache

      @db.setcache(conf[:rcnum], conf[:lcnum], conf[:ncnum])

      #
      # set xmsiz

      @db.setxmsiz(conf[:xmsiz])

      #
      # set dfunit (TC > 1.4.21)

      @db.setdfunit(conf[:dfunit]) if @db.respond_to?(:setdfunit)

      #
      # no default

      @default_proc = nil

      #
      # open

      @path = conf[:path]

      @db.open(@path, conf[:mode]) || raise_error
    end

    # Returns the path to this table.
    #
    def path

      @path
    end

    protected

    def table_query_class #:nodoc#

      TokyoCabinet::TDBQRY
    end
  end
end

