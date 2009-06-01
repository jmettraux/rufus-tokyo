
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
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  it 'should respond to stat' do

    stat = @db.stat
    stat['type'].should.equal('hash')
  end

  it 'should get put value' do

    @db['alpha'] = 'bravo'
    @db['alpha'].should.equal('bravo')
  end

  it 'should count entries' do

    @db.size.should.equal(0)
    3.times { |i| @db[i.to_s] = i.to_s }
    @db.size.should.equal(3)
  end

  it 'should delete entries' do

    @db['alpha'] = 'bravo'
    @db.delete('alpha').should.equal('bravo')
    @db.size.should.equal(0)
  end

  it 'should iterate entries' do

    3.times { |i| @db[i.to_s] = i.to_s }
    @db.values.should.equal(%w{ 0 1 2 })
  end

  it 'should accept and restitute \0 strings' do
    s = "toto#{0.chr}nada"
    @db[s] = s
    @db[s].should.equal(s)
  end

  it 'should reply to #keys when there are keys containing \0' do

    s = "toto#{0.chr}nada"
    @db[s] = s
    @db.keys.should.equal([ s ])
  end

  it 'should not respond to defrag' do

    lambda() { @db.defrag }.should.raise(NoMethodError)
  end
end


describe 'Rufus::Tokyo::Tyrant #keys' do

  before do
    @n = 50
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
    @n.times { |i| @db["person#{i}"] = 'whoever' }
    @n.times { |i| @db["animal#{i}"] = 'whichever' }
    @db["toto#{0.chr}5"] = 'toto'
  end

  after do
    @db.close
  end

  it 'should return a Ruby Array by default' do

    @db.keys.class.should.equal(::Array)
  end

  it 'should return a Cabinet List when :native => true' do

    l = @db.keys(:native => true)
    l.class.should.equal(Rufus::Tokyo::List)
    l.size.should.equal(2 * @n + 1)
    l.free
  end

  it 'should retrieve forward matching keys when :prefix => "prefix-"' do

    @db.keys(:prefix => 'person').size.should.equal(@n)

    l = @db.keys(:prefix => 'animal', :native => true)
    l.size.should.equal(@n)
    l.free
  end

  it 'should retrieve keys that contain \0' do

    @db.keys.include?("toto#{0.chr}5").should.be.true
  end

  it 'should retrieve forward matching keys when key contains \0' do

    @db.keys(:prefix => 'toto').should.equal([ "toto#{0.chr}5" ])
  end

  it 'should return a limited number of keys when :limit is set' do

    @db.keys(:limit => 20).size.should.equal(20)
  end

  it 'should delete_keys_with_prefix' do

    @db.delete_keys_with_prefix('animal')
    @db.size.should.equal(@n + 1)
    @db.keys(:prefix => 'animal').size.should.equal(0)
  end
end

describe 'Rufus::Tokyo::Tyrant lget/lput/ldelete' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
    3.times { |i| @db[i.to_s] = "val#{i}" }
  end
  after do
    @db.close
  end

  it 'should get multiple values' do

    @db.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1", "2"=>"val2"})
  end

  it 'should put multiple values' do

    @db.lput('3' => 'val3', '4' => 'val4')
    @db.lget(%w{ 2 3 }).should.equal({"2"=>"val2", "3"=>"val3"})
  end

  it 'should delete multiple values' do

    @db.ldelete(%w{ 2 3 })
    @db.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1"})
  end
end

describe 'Rufus::Tokyo::Tyrant#add{int|double}' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  it 'should increment (int)' do

    @db.addint('counter', 1).should.equal(1)
    @db.incr('counter', 1).should.equal(2)
    @db.addint('counter', 2).should.equal(4)
    @db.incr('counter').should.equal(5)
  end

  it 'should fail gracefully if counter has already a [string] value (int)' do

    @db['counter'] = 'a'
    lambda { @db.addint('counter', 1) }.should.raise(Rufus::Tokyo::TokyoError)
    @db['counter'].should.equal('a')
  end

  it 'should increment (double)' do

    @db.adddouble('counter', 1.0).should.equal(1.0)
    @db.incr('counter', 1.5).should.equal(2.5)
    @db.adddouble('counter', 2.2).should.equal(4.7)
  end

  it 'should fail gracefully if counter has already a [string] value (double)' do

    @db['counter'] = 'a'
    lambda {
      @db.adddouble('counter', 1.0)
    }.should.raise(Rufus::Tokyo::TokyoError)
    @db['counter'].should.equal('a')
  end
end

describe 'Rufus::Tokyo::Tyrant (lua extensions)' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  it 'should call lua extensions' do

    @db['toto'] = '0'
    3.times { @db.ext(:incr, 'toto', '1') }
    @db.ext('incr', 'toto', 2) # lax

    @db['toto'].should.equal('5')
  end

  it 'should return nil when function is missing' do

    @db.ext(:missing, 'nada', 'forever').should.equal(nil)
  end
end

describe 'Rufus::Tokyo::Tyrant#putkeep' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  it 'should accept values' do

    @db.putkeep('pillow', 'Shonagon')
    @db.size.should.equal(1)
  end

  it 'should restitute values' do

    @db.putkeep('pillow', 'Shonagon')
    @db['pillow'].should.equal('Shonagon')
  end

  it 'should not overwrite values if already set' do

    @db['pillow'] = 'Shonagon'
    @db['pillow'].should.equal('Shonagon')

    @db.putkeep('pillow', 'Ruby')
    @db['pillow'].should.equal('Shonagon')
  end

  it 'should return true if not yet set' do

    @db.putkeep('pillow', 'Shonagon').should.equal(true)
  end

  it 'should return false if already set' do

    @db['pillow'] = 'Shonagon'
    @db.putkeep('pillow', 'Ruby').should.equal(false)
  end
end
