
#
# Specifying rufus-tokyo
#
# Mon Feb 23 23:24:45 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo/ntyrant'
rescue LoadError
end

if defined?(Rufus::Edo)

  describe 'a missing Tokyo Rufus::Edo::NetTyrant' do

    it 'should raise an error' do

      should.raise(RuntimeError) {
        Rufus::Edo::NetTyrant.new('tyrant.example.com', 45000)
      }
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
  end


  describe 'Rufus::Edo::NetTyrant #keys' do

    before do
      @n = 50
      @cab = Rufus::Edo::NetTyrant.new('127.0.0.1', 45000)
      @cab.clear
      @n.times { |i| @cab["person#{i}"] = 'whoever' }
      @n.times { |i| @cab["animal#{i}"] = 'whichever' }
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

    it 'should return a limited number of keys when :limit is set' do

      @cab.keys(:limit => 20).size.should.equal(20)
    end

    it 'should delete_keys_with_prefix' do

      @cab.delete_keys_with_prefix('animal')
      @cab.size.should.equal(@n)
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

end

