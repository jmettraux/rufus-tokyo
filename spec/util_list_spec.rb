
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
    l = @l.push('a')
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

  it 'should accept strings with \\0' do
    s = "tokyo#{0.chr}cabinet"
    @l << s
    @l.pop.should.equal(s)
  end

  it 'should iterate over values with \\0' do
    @l << 'ab' << "c#{0.chr}d" << 'ef'
    ss = @l.inject('') { |s, e| s << e }
    ss.should.equal("abc#{0.chr}def")
  end

  it 'should pop values with \\0' do
    s = "shinbashi#{0.chr}closet"
    @l << s
    @l.pop.should.equal(s)
  end

  it 'should shift values with \\0' do
    s = "shinbashi#{0.chr}closet"
    @l << s
    @l.shift.should.equal(s)
  end

  it 'should unshift values with \\0' do
    s = "shinbashi#{0.chr}closet"
    @l.unshift(s)
    @l[0].should.equal(s)
  end

  it 'should remove values with \\0' do
    s = "shinbashi#{0.chr}closet"
    @l << s
    @l.delete_at(0).should.equal(s)
  end

  it 'should overwrite values with \\0' do
    s0 = "shinbashi#{0.chr}closet"
    s1 = "sugamo#{0.chr}drawer"
    @l << s0
    @l[0] = s1
    @l[0].should.equal(s1)
  end

  #it 'should delete [multiple] values' do
  #  %w[ a b a c a ].each { |e| @l << e }
  #  @l.delete('a')
  #  @l.to_a.should.equal(%w[ b c ])
  #end
  #it 'should return the deleted value' do
  #  %w[ a b a c a ].each { |e| @l << e }
  #  @l.delete('d').should.be.nil
  #end
  #it 'should return the value of the default block when deleting a missing elt' do
  #  %w[ a b a c a ].each { |e| @l << e }
  #  @l.delete('d') { 'nada' }.should.equal('nada')
  #end

  it 'should not accept non-string values' do
    lambda {
      @l << 2
    }.should.raise(ArgumentError)
  end
end

describe 'Rufus::Tokyo::List' do

  it 'should close itself and return its ruby version upon #release' do

    l = Rufus::Tokyo::List.new << 'a' << 'b' << 'c'
    l.release.should.equal(%w{ a b c })
    l.instance_variable_get(:@pointer).should.be.nil
  end

  it 'can be created from a Ruby Array' do

    l = Rufus::Tokyo::List.new(%w{ a b c })
    l.pointer.is_a?(FFI::Pointer).should.be.true
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

