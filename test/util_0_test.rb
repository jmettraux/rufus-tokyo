
#
# Testing rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo/util'


class UtilZero < Test::Unit::TestCase

  def test_map

    m = Rufus::Tokyo::Map.new
    m['a'] = 'b'
    m['c'] = 'd'

    assert_equal 'b', m['a']
    assert_equal nil, m['Z']

    assert_equal [ 'a', 'c' ], m.keys
    assert_equal [ 'b', 'd' ], m.values

    assert_equal 'a=b&c=d', m.collect { |k, v| "#{k}=#{v}" }.join('&')

    assert_equal 2, m.size
    assert_equal 2, m.length

    m.delete('a')
    assert_equal 1, m.size

    m.clear
    assert_equal 0, m.length

    m.destroy

    assert_raises RuntimeError do
      m['c']
    end
  end
end

