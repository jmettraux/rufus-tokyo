
#
# Testing rufus-tokyo
#
# Mon Jan 26 12:54:32 JST 2009
#

require File.dirname(__FILE__) + '/../test_base'

require 'rufus/tokyo/dystopia/words'


class CabinetZero < Test::Unit::TestCase

  def test_open_missing

    e = assert_raises Rufus::Tokyo::DystopianError do
      db = Rufus::Tokyo::Words.new('tmp/missing.tcw')
    end
  end
end

