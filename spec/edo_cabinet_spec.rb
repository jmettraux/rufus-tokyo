
#
# Specifying rufus-tokyo
#
# Sat Feb 21 22:16:23 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo'
rescue LoadError
  puts "'TokyoCabinet' ruby bindings not available on this ruby platform"
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe 'Rufus::Edo::Cabinet' do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch')
      @db.clear
    end

    after do
      @db.close
    end

    it 'should return its path' do

      @db.path.should.equal('tmp/edo_cabinet_spec.tch')
    end

    it 'should create its underlying file' do

      File.exist?('tmp/cabinet_spec.tch').should.equal(true)
    end

    it 'should be empty initially' do

      @db.size.should.equal(0)
      @db['pillow'].should.be.nil
    end

    it 'should accept values' do

      @db['pillow'] = 'Shonagon'
      @db.size.should.equal(1)
    end

    it 'should restitute values' do

      @db['pillow'] = 'Shonagon'
      @db['pillow'].should.equal('Shonagon')
    end

    it 'should delete values' do

      @db['pillow'] = 'Shonagon'
      @db.delete('pillow').should.equal('Shonagon')
      @db.size.should.equal(0)
    end

    it 'should reply to #keys and #values' do

      keys = %w{ alpha bravo charly delta echo foxtrott }
      keys.each_with_index { |k, i| @db[k] = i.to_s }
      @db.keys.should.equal(keys)
      @db.values.should.equal(%w{ 0 1 2 3 4 5 })
    end

    it 'should reply to #keys when there are keys containing \0' do

      s = "toto#{0.chr}nada"
      @db[s] = s
      @db.keys.should.equal([ s ])
    end

    it 'should return a Ruby hash on merge' do

      @db['a'] = 'A'

      @db.merge({ 'b' => 'B', 'c' => 'C' }).should.equal(
        { 'a' => 'A', 'b' => 'B', 'c' => 'C' })

      @db['b'].should.be.nil

      @db.size.should.equal(1)
    end

    it 'should have more values in case of merge!' do

      @db['a'] = 'A'

      @db.merge!({ 'b' => 'B', 'c' => 'C' })

      @db.size.should.equal(3)
      @db['b'].should.equal('B')
    end
  end

  describe 'Rufus::Edo::Cabinet #keys' do

    before do
      @n = 50
      @cab = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
      @cab.clear
      @n.times { |i| @cab["person#{i}"] = 'whoever' }
      @n.times { |i| @cab["animal#{i}"] = 'whichever' }
      @cab["toto#{0.chr}5"] = 'toto'
    end
    after do
      @cab.close
    end

    it 'should return a Ruby Hash by default' do

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


  describe 'Rufus::Edo::Cabinet' do

    it 'should accept a default value' do

      cab = Rufus::Edo::Cabinet.new(
        'tmp/cabinet_spec_default.tch', :default => '@?!')
      cab['a'] = 'A'
      cab.size.should.equal(1)
      cab['b'].should.equal('@?!')
    end

    it 'should accept a default value (later)' do

      cab = Rufus::Edo::Cabinet.new('tmp/cabinet_spec_default.tch')
      cab.default = '@?!'
      cab['a'] = 'A'
      cab.size.should.equal(1)
      cab['b'].should.equal('@?!')
    end
  end


  describe 'Rufus::Edo::Cabinet lget/lput/ldelete' do

    before do
      @cab = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch')
      @cab.clear
      3.times { |i| @cab[i.to_s] = "val#{i}" }
    end
    after do
      @cab.close
    end

    it 'should get multiple values' do

      @cab.lget(%w{ 0 1 2 }).should.equal(
        {"0"=>"val0", "1"=>"val1", "2"=>"val2"})
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


  describe 'Rufus::Edo::Cabinet' do

    it 'should copy correctly' do

      cab = Rufus::Edo::Cabinet.new('tmp/spec_source.tch')
      5000.times { |i| cab["key #{i}"] = "val #{i}" }
      cab.size.should.equal(5000)
      cab.copy('tmp/spec_target.tch')
      cab.close

      cab = Rufus::Edo::Cabinet.new('tmp/spec_target.tch')
      cab.size.should.equal(5000)
      cab['key 4999'].should.equal('val 4999')
      cab.close

      FileUtils.rm('tmp/spec_source.tch')
      FileUtils.rm('tmp/spec_target.tch')
    end

    it 'should copy compactly' do

      cab = Rufus::Edo::Cabinet.new('tmp/spec_source.tch')
      100.times { |i| cab["key #{i}"] = "val #{i}" }
      50.times { |i| cab.delete("key #{i}") }
      cab.size.should.equal(50)
      cab.compact_copy('tmp/spec_target.tch')
      cab.close

      cab = Rufus::Edo::Cabinet.new('tmp/spec_target.tch')
      cab.size.should.equal(50)
      cab['key 99'].should.equal('val 99')
      cab.close

      fs0 = File.size('tmp/spec_source.tch')
      fs1 = File.size('tmp/spec_target.tch')
      (fs0 > fs1).should.equal(true)

      FileUtils.rm('tmp/spec_source.tch')
      FileUtils.rm('tmp/spec_target.tch')
    end


    it 'should use open with a block will auto close the db correctly' do

      res = Rufus::Edo::Cabinet.open('tmp/spec_source.tch') do |cab|
        10.times { |i| cab["key #{i}"] = "val #{i}" }
        cab.size.should.equal(10)
      end

      res.should.be.nil

      cab = Rufus::Edo::Cabinet.new('tmp/spec_source.tch')
      10.times do |i|
        cab["key #{i}"].should.equal("val #{i}")
      end
      cab.close

      FileUtils.rm('tmp/spec_source.tch')
    end


    it 'should use open without a block just like calling new correctly' do

      cab = Rufus::Edo::Cabinet.open('tmp/spec_source.tch')
      10.times { |i| cab["key #{i}"] = "val #{i}" }
      cab.size.should.equal(10)
      cab.close

      cab = Rufus::Edo::Cabinet.new('tmp/spec_source.tch')
      10.times do |i|
        cab["key #{i}"].should.equal("val #{i}")
      end
      cab.close

      FileUtils.rm('tmp/spec_source.tch')
    end

    it 'should honour the :type parameter' do

      cab = Rufus::Edo::Cabinet.open('tmp/toto.tch')
      cab.clear
      cab['hello'] = 'world'
      cab.close

      cab = Rufus::Edo::Cabinet.open('tmp/toto', :type => :hash)
      cab['hello'].should.equal('world')
      cab.close

      FileUtils.rm('tmp/toto.tch')
    end
  end

  describe "Rufus::Edo::Cabinet's transactions" do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_tran_spec.tch')
      @db.clear
    end

    after do
      @db.close
    end

    it 'should correctly abort transactions' do

      @db.transaction {
        @db['pk0'] = 'alpha'
        @db.abort
      }
      @db.size.should.be.zero
    end

    it 'should rollback transactions with errors' do

      @db.transaction {
        @db['pk0'] = 'alpha'
        raise "something goes wrong"
      }
      @db.size.should.be.zero
    end

    it 'should commit successful transactions' do

      @db.transaction do
        @db['pk0'] = 'alpha'
      end
      @db['pk0'].should.equal('alpha')
    end

    it 'should abort low level transactions' do

      @db.tranbegin
      @db['pk0'] = 'alpha'
      @db.tranabort
      @db.size.should.be.zero
    end

    it 'should commit low level transactions' do

      @db.tranbegin
      @db['pk0'] = 'alpha'
      @db.trancommit
      @db['pk0'].should.equal('alpha')
    end
  end

  describe 'Rufus::Edo::Cabinet#add{int|double}' do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
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

  describe 'Rufus::Edo::Cabinet#putkeep' do
    before do
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
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

