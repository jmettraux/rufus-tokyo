
#
# Specifying rufus-tokyo
#
# Sun Feb  8 15:02:08 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'

FileUtils.mkdir('tmp') rescue nil


describe 'Rufus::Tokyo::Cabinet' do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end

  after do
    @db.close
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

describe 'Rufus::Tokyo::Cabinet #keys' do

  before do
    @n = 50
    @cab = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @cab.clear
    @n.times { |i| @cab["person#{i}"] = 'whoever' }
    @n.times { |i| @cab["animal#{i}"] = 'whichever' }
  end

  after do
    @cab.close
  end

  it 'should return a Ruby Hash by default' do

    @cab.keys.class.should.equal(::Array)
  end

  it 'should return a Cabinet List when :native => true' do

    l = @cab.keys(:native => true)
    l.class.should.equal(Rufus::Tokyo::List)
    l.size.should.equal(@n * 2)
    l.free
  end

  it 'should retrieve forward matching keys when :prefix => "prefix-"' do

    @cab.keys(:prefix => 'person').size.should.equal(@n)

    l = @cab.keys(:prefix => 'animal', :native => true)
    l.size.should.equal(@n)
    l.free
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

if Rufus::Tokyo::CabinetLib.respond_to?(:tcadbtranbegin)
  #
  # TC >= 1.4.13

  describe Rufus::Tokyo::Cabinet do

    before do
      @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
      @db.clear
    end

    after do
      @db.close
    end

    it 'should correctly abort transactions' do

      @db.transaction {
        @db['pk0'] = 'value0'
        @db.abort
      }
      @db.size.should.be.zero
    end

    it 'should rollback transactions with errors' do

      @db.transaction {
        @db['pk0'] = 'value0'
        raise 'something goes wrong'
      }
      @db.size.should.be.zero
    end

    it 'should commit successful transactions' do

      @db.transaction do
        @db['pk0'] = 'showanojidaietaminamishima'
      end
      @db['pk0'].should.equal('showanojidaietaminamishima')
    end

    it 'should abort low level transactions' do

      @db.tranbegin
      @db['pk0'] = 'shikataganai'
      @db.tranabort
      @db.size.should.be.zero
    end

    it 'should commit low level transactions' do

      @db.tranbegin
      @db['pk0'] = 'shikataganai'
      @db.trancommit
      @db['pk0'].should.equal('shikataganai')
    end
  end
end


describe 'Rufus::Tokyo::Cabinet' do

  it 'should accept a default value' do

    cab = Rufus::Tokyo::Cabinet.new(
      'tmp/cabinet_spec_default.tch', :default => '@?!')
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
  end

  it 'should accept a default value (later)' do

    cab = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec_default.tch')
    cab.default = '@?!'
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
  end
end

describe 'Rufus::Tokyo::Cabinet lget/lput/ldelete' do

  before do
    @cab = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
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


describe 'Rufus::Tokyo::Cabinet' do

  it 'should copy correctly' do

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_source.tch')
    5000.times { |i| cab["key #{i}"] = "val #{i}" }
    cab.size.should.equal(5000)
    cab.copy('tmp/spec_target.tch')
    cab.close

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_target.tch')
    cab.size.should.equal(5000)
    cab['key 4999'].should.equal('val 4999')
    cab.close

    FileUtils.rm('tmp/spec_source.tch')
    FileUtils.rm('tmp/spec_target.tch')
  end

  it 'should copy compactly' do

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_source.tch')
    100.times { |i| cab["key #{i}"] = "val #{i}" }
    50.times { |i| cab.delete("key #{i}") }
    cab.size.should.equal(50)
    cab.compact_copy('tmp/spec_target.tch')
    cab.close

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_target.tch')
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

    res = Rufus::Tokyo::Cabinet.open('tmp/spec_source.tch') do |cab|
      10.times { |i| cab["key #{i}"] = "val #{i}" }
      cab.size.should.equal(10)
    end

    res.should.be.nil

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_source.tch')
    10.times do |i|
      cab["key #{i}"].should.equal("val #{i}")
    end
    cab.close

    FileUtils.rm('tmp/spec_source.tch')
  end


  it 'should use open without a block just like calling new correctly' do

    cab = Rufus::Tokyo::Cabinet.open('tmp/spec_source.tch')
    10.times { |i| cab["key #{i}"] = "val #{i}" }
    cab.size.should.equal(10)
    cab.close

    cab = Rufus::Tokyo::Cabinet.new('tmp/spec_source.tch')
    10.times do |i|
      cab["key #{i}"].should.equal("val #{i}")
    end
    cab.close

    FileUtils.rm('tmp/spec_source.tch')
  end

  it 'should honour the :type parameter' do

    cab = Rufus::Tokyo::Cabinet.open('tmp/toto.tch')
    cab.clear
    cab['hello'] = 'world'
    cab.close

    cab = Rufus::Tokyo::Cabinet.open('tmp/toto', :type => :hash)
    cab['hello'].should.equal('world')
    cab.close

    FileUtils.rm('tmp/toto.tch')
  end

end

