
#
# Specifying rufus-tokyo
#
# Tue Jan 27 16:30:34 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'


describe 'Rufus::Tokyo::List' do

  before do
    @l = Rufus::Tokyo::List.new
  end
  after do
    @l.free
  end

  it 'should be empty initially' do

    @l.size.should.be.zero
  end

end

