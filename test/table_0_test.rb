
#
# Testing rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo/table'


class TableZero < Test::Unit::TestCase

  def test_open_missing

    e = assert_raises Rufus::Tokyo::TokyoError do
      Rufus::Tokyo::Table.new('missing.tdb')
    end

    assert_equal '(err 3) file not found', e.message
  end

  def test_create

    t = Rufus::Tokyo::Table.new('test_new.tdb', :create, :write)

    assert t.genuid > 0, 'unique id is 0, bad'
    assert t.generate_unique_id > 0, 'unique id is 0, bad'

    t.tabbed_put('toto', 'rage', 'against', 'the', 'kikai')

    t.close
  end
end

