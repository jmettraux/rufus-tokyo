
#
# Specifying rufus-tokyo
#
# Sun Feb  8 16:01:51 JST 2009
#

require File.dirname(__FILE__)+'/spec_base'

describe 'open modes' do

  it 'should grant write/create by default' do
    Rufus::Tokyo.compute_open_mode({}).should.equal(6)
  end

  it 'should respect :readonly => true' do
    Rufus::Tokyo.compute_open_mode({ :readonly => true }).should.equal(0)
    Rufus::Tokyo.compute_open_mode({ :read_only => true }).should.equal(0)
    Rufus::Tokyo.compute_open_mode([ :read_only ]).should.equal(0)
  end

  it 'should be determined correctly' do
    Rufus::Tokyo.compute_open_mode(:no_lock => true).should.equal(22)
    Rufus::Tokyo.compute_open_mode([:no_lock, :reader]).should.equal(23)
    Rufus::Tokyo.compute_open_mode([:no_lock, :create]).should.equal(22)
  end

end

