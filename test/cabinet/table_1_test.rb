
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
    @tdb['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
    @tdb['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
    @tdb['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
  end

  def teardown
    @tdb.close
  end

  def test_prepare_query

    q = @tdb.prepare_query { |q|
      q.add 'lang', :includes, 'en'
    }
    rs = q.run

    assert_equal 4, rs.size

    rs.close

    q.limit 2

    rs = q.run

    assert_equal 2, rs.size

    q.close
  end

  def test_limit

    rs = @tdb.do_query { |q|
      q.add 'lang', :includes, 'en'
      q.order_by 'name', :desc
      q.limit 2 # set_max
    }

    assert_equal 2, rs.size

    assert_equal(
      [
        {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
        {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"}
      ],
      rs.to_a)

    rs.free
  end

  def test_order_strasc

    assert_equal(
      [
        {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
        {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"},
        {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"},
        {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"}
      ],
      @tdb.query { |q|
        q.add 'lang', :includes, 'en'
        q.order_by 'name', :asc
      })
  end

  def test_order_numasc

    assert_equal(
      [
        {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
        {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"},
        {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
        {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"}
      ],
      a = @tdb.query { |q|
        q.add 'lang', :includes, 'en'
        q.order_by 'age', :numasc
      })
  end

  def test_matches

    assert_equal(
      [
        {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
        {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"}
      ],
      a = @tdb.query { |q|
        q.add 'name', :matches, '^j.+k'
      })
  end

  def test_no_pk

    assert_equal(
      [
        {"name"=>"jack", "lang"=>"en", "age"=>"44"},
        {"name"=>"jake", "lang"=>"en,li", "age"=>"45"}
      ],
      a = @tdb.query { |q|
        q.add 'name', :matches, '^j.+k'
        q.no_pk
      })
  end

  def test_pk_only

    assert_equal(
      [ 'pk2', 'pk3' ],
      a = @tdb.query { |q|
        q.add 'name', :matches, '^j.+k'
        q.pk_only
      })
  end

  def test_condition_numerical_gt

    assert_equal(
      [ 'pk2', 'pk3' ],
      a = @tdb.query { |q|
        q.add 'age', :gt, '40'
        q.pk_only
      })
  end

  def test_condition_negate

    assert_equal(
      [ 'pk0', 'pk1' ],
      a = @tdb.query { |q|
        q.add 'age', :gt, '40', false
        q.pk_only
      })
  end

  def test_quack_like_a_hash

    assert_equal [ "pk0", "pk1", "pk2", "pk3" ], @tdb.keys

    assert_equal(
      [
        { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' },
        { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' },
        { 'name' => 'jack', 'age' => '44', 'lang' => 'en' },
        { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
      ],
      @tdb.values)

    assert_equal(
      [ 'pk1', { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' } ],
      @tdb.find { |k, v| v['name'] == 'jeff' })
  end
end

