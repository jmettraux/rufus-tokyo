
#
# Testing rufus-tokyo
#
# Fri Jan 23 08:31:01 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'test/unit'

require 'rufus/tokyo'


class CabinetZero < Test::Unit::TestCase

  #def setup
  #end
  #def teardown
  #end

  def test_lib

    assert_not_nil Rufus::Tokyo.lib
  end

  def test_basic_workflow

    db = Rufus::Tokyo::Cabinet.new('test_data.tch')
    db['pillow'] = 'Shonagon'

    assert_equal 1, db.size
    assert_equal 'Shonagon', db['pillow']

    assert_equal 'Shonagon', db.delete('pillow')
    assert_equal 0, db.size

    assert db.close
  end

  def test_clear

    db = Rufus::Tokyo::Cabinet.new('test_data.tch')

    40.times { |i| db[i.to_s] = i.to_s }
    assert_equal 40, db.size

    db.clear

    assert_equal 0, db.size

    assert db.close
  end

end

