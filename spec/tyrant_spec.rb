
#
# Specifying rufus-tokyo
#
# Sun Feb  8 13:13:41 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo/tyrant'


describe 'a missing Tokyo Rufus::Tokyo::Tyrant' do

  it 'should raise an error' do

    should.raise(RuntimeError) {
      Rufus::Tokyo::Tyrant.new('tyrant.example.com', 45000)
    }
  end
end

describe 'a Tokyo Rufus::Tokyo::Tyrant' do

  it 'should open and close' do

    should.not.raise {
      t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
      t.close
    }
  end

  it 'should refuse to connect to a TyrantTable' do

    lambda {
      t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45001)
    }.should.raise(ArgumentError)
  end
end

describe 'a Tokyo Rufus::Tokyo::Tyrant' do

  before do
    @t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    #puts @t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
    @t.clear
  end
  after do
    @t.close
  end

  it 'should respond to stat' do

    stat = @t.stat
    stat['type'].should.equal('hash')
  end

  it 'should get put value' do

    @t['alpha'] = 'bravo'
    @t['alpha'].should.equal('bravo')
  end

  it 'should count entries' do

    @t.size.should.equal(0)
    3.times { |i| @t[i.to_s] = i.to_s }
    @t.size.should.equal(3)
  end

  it 'should delete entries' do

    @t['alpha'] = 'bravo'
    @t.delete('alpha').should.equal('bravo')
    @t.size.should.equal(0)
  end

  it 'should iterate entries' do

    3.times { |i| @t[i.to_s] = i.to_s }
    @t.values.should.equal(%w{ 0 1 2 })
  end
end

