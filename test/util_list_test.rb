
#
# Testing rufus-tokyo
#
# Tue Jan 27 16:30:34 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo/cabinet/util'


class UtilOne < Test::Unit::TestCase

  def test_list_0

    l = Rufus::Tokyo::List.new

    assert_nil l.pop
    assert_nil l.shift

    l << 'alpha'
    l << 'bravo'
    l << 'charly'

    assert_equal 3, l.size
    assert_equal 'bravo', l[1]
    assert_equal 'charly', l[-1]
    assert_equal %w{ alpha bravo }, l[0, 2]
    assert_equal %w{ alpha bravo charly }, l[0..-1]
    assert_equal %w{ alpha bravo }, l[0..1]
    assert_nil l[0, -1]

    assert_equal %w{ ALPHA BRAVO CHARLY }, l.collect { |e| e.upcase }

    assert_equal 'charly', l.pop
    assert_equal 2, l.size

    l.unshift('delta')
    assert_equal 3, l.size

    assert_equal 'delta', l.shift
    assert_equal 2, l.size

    l.push 'echo', 'foxtrott'
    assert_equal 4, l.size

    l.close
  end

  def test_list_1

    l = Rufus::Tokyo::List.new

    #assert_raises RuntimeError do
    #  l << nil
    #end

    l << '-'
    l << '-'
    l << '-'
    l << '-'
    l << '4'

    l[0, 3] = [ 'a', 'b', 'c' ]
    assert_equal %w{ a b c - 4 }, l.to_a

    l[1..2] = [ '1', '2' ]
    assert_equal %w{ a 1 2 - 4 }, l.to_a

    l[0, 2] = '?'
    assert_equal %w{ ? 2 - 4 }, l.to_a

    l[0..2] = 'A'
    assert_equal %w{ A 4 }, l.to_a

    l[-1] = 'Z'
    assert_equal %w{ A Z }, l.to_a

    l[1..-1] = nil
    assert_equal %w{ A }, l.to_a

    l.free
  end
end

