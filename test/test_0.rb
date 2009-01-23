
#
# Testing rufus-tokyo
#
# Fri Jan 23 08:31:01 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'test/unit'

require 'rufus/tokyo'


class TestZero < Test::Unit::TestCase

  #def setup
  #end
  #def teardown
  #end

  def test_basic_workflow

    db = Rufus::Tokyo::Cabinet.new('test_data.tch')
    db['pillow'] = 'Shonagon'

    assert_equal 1, db.size
    assert_equal 'Shonagon', db['pillow']

    assert_equal 'Shonagon', db.delete('pillow')
    assert_equal 0, db.size

    assert db.close
  end

  # TODO : memory tests

end

