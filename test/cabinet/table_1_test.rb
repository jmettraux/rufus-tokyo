
#
# Testing rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

require File.dirname(__FILE__) + '/../test_base'

require 'rufus/tokyo/cabinet/table'


class TableOne < Test::Unit::TestCase

  def setup
    @tdb = Rufus::Tokyo::Table.new('test_new.tdb', :create, :write)
    @tdb.clear
    @tdb['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
    @tdb['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,sp' }
    @tdb['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
  end

  def teardown
    @tdb.close
  end

  def test_prepare_query

    q = @tdb.prepare_query { |q|
      q.add 'lang', :eq, 'en'
    }
    rs = q.run

    assert_equal 3, rs.size

    rs.close

    q.limit 2

    rs = q.run

    assert_equal 2, rs.size

    q.close
  end

  def test_limit

    rs = @tdb.do_query { |q|
      q.add 'lang', :eq, 'en'
      q.order_by 'name', :desc
      q.limit 2 # set_max
    }

    assert_equal 2, rs.size

    assert_equal(
      [
        {"name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
        {"name"=>"jeff", "lang"=>"en,sp", "age"=>"32"}
      ],
      rs.to_a)

    rs.free
  end

  def test_order

    a = @tdb.query { |q|
      q.add 'lang', :eq, 'en'
      q.order_by 'name', :asc
    }

    assert_equal(
      [
        {"name"=>"jack", "lang"=>"en", "age"=>"44"},
        {"name"=>"jeff", "lang"=>"en,sp", "age"=>"32"},
        {"name"=>"jim", "lang"=>"ja,en", "age"=>"25"}
      ],
      a)

    a = @tdb.query { |q|
      q.add 'lang', :eq, 'en'
      q.order_by 'age', :numdesc
    }

    assert_equal(
      [
        {"name"=>"jack", "lang"=>"en", "age"=>"44"},
        {"name"=>"jeff", "lang"=>"en,sp", "age"=>"32"},
        {"name"=>"jim", "lang"=>"ja,en", "age"=>"25"}
      ],
      a)
  end

  def _test_matches

    a = @tdb.query { |q|
      q.add 'name', :matches, '.*'
    }

    assert_equal(
      [
        {"name"=>"jeff", "lang"=>"en,sp", "age"=>"32"},
      ],
      a)
  end
end

