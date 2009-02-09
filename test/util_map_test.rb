
#
# Testing rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

%w{ lib }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $: << path unless $:.include?(path)
end

require 'test/unit'

require 'rufus/tokyo/cabinet/util'


class UtilZero < Test::Unit::TestCase

  def test_map_0

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

  def test_map_to_from_h

    h = { 'a' => 'A', 'b' => 'B' }
    m = Rufus::Tokyo::Map.from_h(h)

    assert_equal 'A', m['a']

    h1 = m.to_h
    assert_kind_of Hash, h1
    assert_equal h, h1

    m.free
  end

  def test_map_merge

    m = Rufus::Tokyo::Map.from_h({ 'a' => 'A', 'b' => 'B' })
    m.merge!('c' => 'C')

    assert_equal 3, m.size

    m.free
  end
end

