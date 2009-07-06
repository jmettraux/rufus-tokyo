
#
# Specifying rufus-tokyo
#
# Mon Feb 23 23:24:45 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo/ntyrant'
rescue LoadError
  puts "'TokyoTyrant' ruby lib not available on this ruby platform"
end

if defined?(Rufus::Edo)

  describe 'a missing Tokyo Rufus::Edo::NetTyrant' do

    it 'should raise an error' do

      lambda {
        Rufus::Edo::NetTyrant.new('tyrant.example.com', 45000)
      }.should.raise(Rufus::Edo::EdoError).message.should.equal(
        '(err 2) host not found')
    end
  end

  describe 'Rufus::Edo::NetTyrant' do

    it 'should open and close' do

      should.not.raise {
        t = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
        t.close
      }
    end

    it 'should refuse to connect to a TyrantTable' do

      lambda {
        t = Rufus::Edo::NetTyrant.new('127.0.0.1', 45001)
      }.should.raise(ArgumentError)
    end
  end

  describe 'Rufus::Edo::NetTyrant' do

    before do
      @t = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
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

    it 'should accept and restitute \0 strings' do
      s = "toto#{0.chr}nada"
      @t[s] = s
      @t[s].should.equal(s)
    end

    it 'should reply to #keys when there are keys containing \0' do

      s = "toto#{0.chr}nada"
      @t[s] = s
      @t.keys.should.equal([ s ])
    end
  end


  describe 'Rufus::Edo::NetTyrant #keys' do

    before do
      @n = 50
      @cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @cab.clear
      @n.times { |i| @cab["person#{i}"] = 'whoever' }
      @n.times { |i| @cab["animal#{i}"] = 'whichever' }
      @cab["toto#{0.chr}5"] = 'toto'
    end

    after do
      @cab.close
    end

    it 'should return a Ruby Array' do

      @cab.keys.class.should.equal(::Array)
    end

    it 'should retrieve forward matching keys when :prefix => "prefix-"' do

      @cab.keys(:prefix => 'person').size.should.equal(@n)
    end

    it 'should retrieve keys that contain \0' do

      @cab.keys.include?("toto#{0.chr}5").should.be.true
    end

    it 'should retrieve forward matching keys when key contains \0' do

      @cab.keys(:prefix => 'toto').should.equal([ "toto#{0.chr}5" ])
    end

    it 'should return a limited number of keys when :limit is set' do

      @cab.keys(:limit => 20).size.should.equal(20)
    end

    it 'should delete_keys_with_prefix' do

      @cab.delete_keys_with_prefix('animal')
      @cab.size.should.equal(@n + 1)
      @cab.keys(:prefix => 'animal').size.should.equal(0)
    end
  end

  describe 'Rufus::Edo::NetTyrant lget/lput/ldelete' do

    before do
      @cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @cab.clear
      3.times { |i| @cab[i.to_s] = "val#{i}" }
    end
    after do
      @cab.close
    end

    it 'should get multiple values' do

      @cab.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1", "2"=>"val2"})
    end

    it 'should put multiple values' do

      @cab.lput('3' => 'val3', '4' => 'val4')
      @cab.lget(%w{ 2 3 }).should.equal({"2"=>"val2", "3"=>"val3"})
    end

    it 'should delete multiple values' do

      @cab.ldelete(%w{ 2 3 })
      @cab.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1"})
    end
  end

  describe 'Rufus::Edo::NetTyrant#add{int|double}' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    it 'should increment (int)' do

      @db.addint('counter', 1).should.equal(1)
      @db.incr('counter', 1).should.equal(2)
      @db.addint('counter', 2).should.equal(4)
      @db.incr('counter', 1).should.equal(5)
    end

    it 'should fail gracefully if counter has already a [string] value (int)' do

      @db['counter'] = 'a'
      lambda { @db.addint('counter', 1) }.should.raise(Rufus::Edo::EdoError)
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
      }.should.raise(Rufus::Edo::EdoError)
      @db['counter'].should.equal('a')
    end
  end

  describe 'Rufus::Tokyo::Tyrant (lua extensions)' do

    before do
      @cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @cab.clear
    end
    after do
      @cab.close
    end

    it 'should call lua extensions' do

      @cab['toto'] = '0'
      3.times { @cab.ext(:incr, 'toto', '1') }
      @cab.ext('incr', 'toto', 2) # lax

      @cab['toto'].should.equal('5')
    end

    it 'should return nil when function is missing' do

      @cab.ext(:missing, 'nada', 'forever').should.equal(nil)
    end
  end

  describe 'Rufus::Edo::NetTyrant#putkeep' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
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

    it 'should accept binary data \0' do

      s = "Sei#{0.chr}Shonagon"

      @db.putkeep(s, s).should.be.true
      @db[s].should.equal(s)
    end
  end
end

