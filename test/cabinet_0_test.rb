
#
# Testing rufus-tokyo
#
# Fri Jan 23 08:31:01 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo'
#require 'rufus/tokyo/cabinet'


class CabinetZero < Test::Unit::TestCase

  def setup
    @db = Rufus::Tokyo::Cabinet.new('test_data.tch')
    @db.clear
  end
  def teardown
    @db.close
  end
  def db
    @db
  end

  def test_lib

    assert_not_nil Rufus::Tokyo::Cabinet.lib
  end

  def test_basic_workflow

    db['pillow'] = 'Shonagon'

    assert_equal 1, db.size
    assert_equal 'Shonagon', db['pillow']

    assert_equal 'Shonagon', db.delete('pillow')
    assert_equal 0, db.size
  end

  def test_clear

    db = Rufus::Tokyo::Cabinet.new('test_data.tch')
    db.clear

    40.times { |i| db[i.to_s] = i.to_s }
    assert_equal 40, db.size
  end

  def test_keys_and_values

    db = Rufus::Tokyo::Cabinet.new('test_data.tch')
    db.clear

    keys = %w{ alpha bravo charly delta echo foxtrott }

    keys.each_with_index { |k, i| db[k] = i.to_s }

    assert_equal keys, db.keys
    assert_equal %w{ 0 1 2 3 4 5 }, db.values
  end

end

