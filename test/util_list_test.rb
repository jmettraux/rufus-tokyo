
#
# Testing rufus-tokyo
#
# Tue Jan 27 16:30:34 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo/util'


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
    #assert_equal %w{ alpha bravo }, l[0, 2]
    #assert_equal %w{ alpha bravo }, l[0..1]

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
end

