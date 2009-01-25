
#
# Testing rufus-tokyo
#
# Sun Jan 25 12:26:48 JST 2009
#

require File.dirname(__FILE__) + '/test_base'


class CabinetOne < Test::Unit::TestCase

  def test_copy

    cab = Rufus::Tokyo::Cabinet.new('test_source.tch')
    5000.times { |i| cab["key #{i}"] = "val #{i}" }
    2500.times { |i| cab.delete("key #{i}") }
    assert_equal 2500, cab.size
    cab.copy('test_target.tch')
    cab.close

    cab = Rufus::Tokyo::Cabinet.new('test_target.tch')
    assert_equal 2500, cab.size
    cab.close

    FileUtils.rm('test_source.tch')
    FileUtils.rm('test_target.tch')
  end
end

