
#
# Testing rufus-tokyo
#
# Thu Jan 29 11:19:25 JST 2009
#

require File.dirname(__FILE__) + '/../test_base'

require 'rufus/tokyo/hmethods'


class HmethodsTest < Test::Unit::TestCase

  class MyHash
    attr_accessor :default_proc
    def get (k)
      k.to_i % 2 == 0 ? k : nil
    end
  end

  def setup
    @h = MyHash.new
    @h.extend(Rufus::Tokyo::HashMethods)
  end

  def test_myhash

    assert_equal nil, @h[1]
    assert_equal 2, @h[2]
  end

  def test_default

    @h.default = :default

    assert_equal :default, @h.default

    assert_equal :default, @h[1]
    assert_equal 2, @h[2]
  end

  def test_default_proc

    @h.default_proc = lambda { |h, k| k * 2 }

    assert_equal 2, @h[1]
    assert_equal 2, @h[2]
    assert_equal 6, @h[3]
  end
end

