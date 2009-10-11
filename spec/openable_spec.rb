require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo/openable'


class MyOpenable
  extend Rufus::Tokyo::Openable

  def initialize(*args)
    @args   = args
    @closed = false
  end
  
  attr_reader :args

  def close
    @closed = true
  end
  
  def closed?
    @closed
  end
end
openable = lambda { |obj| obj.is_a? MyOpenable }

describe 'an instance that extends Openable' do
  it 'should pass all arguments from open() down to new()' do
    MyOpenable.open(1).args.should.equal([1])
    MyOpenable.open(1, 2).args.should.equal([1, 2])
  end
  
  it 'should pass the constructed object into the block' do
    MyOpenable.open { |o| o.should.be openable }
  end
  
  it 'should return the last value in the block' do
    MyOpenable.open { :value }.should.equal(:value)
  end
  
  it 'should return the new object without a block' do
    MyOpenable.open.should.be openable
  end
  
  it 'should call close after running the block' do
    MyOpenable.open { |db| db.should.not.be.closed; db }.should.be.closed
  end
  
  it 'should not be closed when opened without a block' do
    MyOpenable.open.should.not.be.closed
  end
end
