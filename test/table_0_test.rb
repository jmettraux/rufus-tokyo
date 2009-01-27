
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

  def test_tabbed_put

    t = Rufus::Tokyo::Table.new('test_new.tdb', :create, :write)
    t.clear

    assert_equal 0, t.size

    assert t.genuid > 0, 'unique id is 0, bad'
    assert t.generate_unique_id > 0, 'unique id is 0, bad'

    t.tabbed_put('toto', 'name', 'toto', 'age', '3')
    t.tabbed_put('fred', 'name', 'fred', 'age', '4')

    assert_equal 2, t.size

    t.close
  end

  def test_put

    t = Rufus::Tokyo::Table.new('test_new.tdb', :create, :write)
    t.clear

    t['pk0'] = [ 'name', 'alfred', 'age', '22']
    t['pk1'] = { 'name' => 'jim', 'age' => '23' }

    assert_equal 2, t.size

    assert_equal({ 'name' => 'jim', 'age' => '23' }, t['pk1'])

    t.delete('pk0')

    assert_equal 1, t.size

    assert_nil t['pk0']

    t.close
  end

  def _test_query

    t = Rufus::Tokyo::Table.new('test_new.tdb', :create, :write)
    t.clear

    t['pk0'] = { 'name' => 'jim', 'age' => '23', 'lang' => 'ja,en' }
    t['pk1'] = { 'name' => 'jeff', 'age' => '23', 'lang' => 'en,sp' }
    t['pk2'] = { 'name' => 'jack', 'age' => '23', 'lang' => 'en' }

    rs = t.query { |q|
      q.add 'lang', :or, 'ja,en'
      q.order_by 'name'
      q.limit 10 # set_max
    }

    assert_equal [], rs.to_a

    rs.free

    t.close
  end
end

