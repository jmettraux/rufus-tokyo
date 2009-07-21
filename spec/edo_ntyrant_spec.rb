
#
# Specifying rufus-tokyo
#
# Mon Feb 23 23:24:45 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'
require File.dirname(__FILE__) + '/shared_abstract_spec'

begin
  require 'rufus/edo/ntyrant'
rescue LoadError
  puts "'TokyoTyrant' ruby lib not available on this ruby platform"
end

if defined?(Rufus::Edo)

  describe 'a missing Rufus::Edo::NetTyrant' do

    it 'should raise an error' do

      lambda {
        Rufus::Edo::NetTyrant.new('tyrant.example.com', 45000)
      }.should.raise(Rufus::Edo::EdoError).message.should.equal(
        '(err 2) host not found')
    end
  end

  describe Rufus::Edo::NetTyrant do

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

  describe Rufus::Edo::NetTyrant do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      #puts @t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like "an abstract structure"

    it 'should respond to stat' do

      stat = @db.stat
      stat['type'].should.equal('hash')
    end
  end

  describe Rufus::Edo::NetTyrant do

    before do
      @n = 50
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
      @n.times { |i| @db["person#{i}"] = 'whoever' }
      @n.times { |i| @db["animal#{i}"] = 'whichever' }
      @db["toto#{0.chr}5"] = 'toto'
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #keys'
  end

  describe 'Rufus::Edo::NetTyrant lget/lput/ldelete' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
      3.times { |i| @db[i.to_s] = "val#{i}" }
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #lget/lput/ldelete'
  end

  describe 'Rufus::Edo::NetTyrant#add{int|double}' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #add{int|double}'
  end

  describe 'Rufus::Edo::NetTyrant#putkeep' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #putkeep'
  end

  describe 'Rufus::Tokyo::Tyrant (lua extensions)' do

    before do
      @db = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'tyrant with embedded lua'
  end
end

