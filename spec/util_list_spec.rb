
#
# Specifying rufus-tokyo
#
# Tue Jan 27 16:30:34 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'


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

  it 'should respond to <<' do
    l = @l << 'a'
    @l.size.should.equal(1)
    l.should.equal(@l)
  end

  it 'should respond to push' do
    l = @l << 'a'
    @l.size.should.equal(1)
    l.should.equal(@l)
  end

  it 'should respond to push with multiple arguments' do
    @l.push('a', 'b', 'c')
    @l.size.should.equal(3)
  end

  it 'should respond to pop' do
    @l.pop.should.be.nil
  end

  it 'should respond to shift' do
    @l.shift.should.be.nil
  end

  unless defined?(JRUBY_VERSION)
    it 'should not accept non-string values' do
      lambda {
        @l << 2
      }.should.raise(ArgumentError)
    end
  end

end

describe 'Rufus::Tokyo::List' do

  it 'should close itself and return its ruby version upon #release' do
    l = Rufus::Tokyo::List.new << 'a' << 'b' << 'c'
    l.release.should.equal(%w{ a b c })
    l.instance_variable_get(:@list).should.be.nil
  end
end

describe 'Rufus::Tokyo::List' do

  before do
    @l = Rufus::Tokyo::List.new
    @l << 'a' << 'b' << 'c' << 'd'
  end
  after do
    @l.free
  end

  it 'should respond to pop' do
    @l.pop.should.equal('d')
    @l.size.should.equal(3)
  end

  it 'should respond to shift' do
    @l.shift.should.equal('a')
    @l.size.should.equal(3)
  end

  it 'should respond to unshift' do
    @l.unshift('z')
    @l.size.should.equal(5)
  end

  it 'should slice correctly' do
    @l[1].should.equal('b')
    @l[-1].should.equal('d')
    @l[0, 2].should.equal(%w{ a b })
    @l[0..-1].should.equal(%w{ a b c d })
    @l[0..1].should.equal(%w{ a b })
    @l[0, -1].should.be.nil
  end
end

describe 'Rufus::Tokyo::List' do

  before do
    @l = Rufus::Tokyo::List.new
    @l.push(*%w{ - - - - e })
  end
  after do
    @l.free
  end

  it 'should overwrite slices (0)' do
    @l[0, 3] = %w{ a b c }
    @l.to_a.should.equal(%w{ a b c - e })
  end

  it 'should overwrite slices (1)' do
    @l[1..2] = %w{ a b }
    @l.to_a.should.equal(%w{ - a b - e })
  end

  it 'should overwrite slices (2)' do
    @l[0, 2] = '?'
    @l.to_a.should.equal(%w{ ? - - e })
  end

  it 'should overwrite slices (3)' do
    @l[0..2] = '?'
    @l.to_a.should.equal(%w{ ? - e })
  end
end

