
#
# Testing rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

require File.dirname(__FILE__) + '/test_base'

require 'rufus/tokyo/base'


class ApiZero < Test::Unit::TestCase

  def test_compute_open_mode

    o = Object.new
    o.extend(Rufus::Tokyo::TokyoContainerMixin)

    assert_equal 0, o.compute_open_mode({})
    assert_equal 16, o.compute_open_mode(:no_lock => true)
    assert_equal 17, o.compute_open_mode([:no_lock, :reader])
    assert_equal 20, o.compute_open_mode([:no_lock, :create])
  end
end

