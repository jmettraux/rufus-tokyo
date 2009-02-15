
#
# Specifying rufus-tokyo
#
# Mon Jan 26 15:10:03 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'


describe 'Rufus::Tokyo::Map' do

  before do
    @m = Rufus::Tokyo::Map.new
  end
  after do
    @m.free
  end

  it 'should be empty initially' do
    @m.size.should.be.zero
  end

  it 'should respond to #size and #length' do
    @m.size.should.be.zero
    @m.length.should.be.zero
  end

  it 'should return nil when there is no value for a key' do
    @m['missing'].should.be.nil
  end

  it 'should accept input' do
    @m['a'] = 'b'
    @m.size.should.equal(1)
  end

  it 'should fetch values' do
    @m['a'] = 'b'
    @m['a'].should.equal('b')
  end

  unless defined?(JRUBY_VERSION)
    it 'should raise an ArgumentError on non-string input' do
      lambda {
        @m[1] = 2
      }.should.raise(ArgumentError)
      lambda {
        @m['a'] = 2
      }.should.raise(ArgumentError)
      lambda {
        @m[1] = 'b'
      }.should.raise(ArgumentError)
    end
  end
end

describe 'Rufus::Tokyo::Map class, like the Ruby Hash class,' do

  it 'should respond to #[]' do
    m = Rufus::Tokyo::Map[ 'a' => 'b' ]
    m.class.should.equal(Rufus::Tokyo::Map)
    m['a'].should.equal('b')
    m.free
  end
end

describe 'Rufus::Tokyo::Map, like a Ruby Hash,' do

  before do
    @m = Rufus::Tokyo::Map[%w{ a A b B c C }]
  end
  after do
    @m.free
  end

  it 'should list keys' do
    @m.keys.should.equal(%w{ a b c })
  end

  it 'should list values' do
    @m.values.should.equal(%w{ A B C })
  end

  it 'should respond to merge (and return a Hash)' do
    h = @m.merge('d' => 'D')
    h.should.equal(::Hash[*%w{ a A b B c C d D }])
    @m.size.should.equal(3)
  end

  it 'should respond to merge! (and return self)' do
    r = @m.merge!('d' => 'D')
    @m.size.should.equal(4)
    r.should.equal(@m)
  end
end

describe 'Rufus::Tokyo::Map, as an Enumerable,' do

  before do
    @m = Rufus::Tokyo::Map[%w{ a A b B c C }]
  end
  after do
    @m.free
  end

  it 'should respond to collect' do
    @m.inject('') { |s, (k, v)| s << "#{k}#{v}" }.should.equal('aAbBcC')
  end
end

