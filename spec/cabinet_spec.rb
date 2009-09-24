
#
# Specifying rufus-tokyo
#
# Sun Feb  8 15:02:08 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'
require File.dirname(__FILE__) + '/shared_abstract_spec'

require 'rufus/tokyo'

FileUtils.mkdir('tmp') rescue nil


describe 'a missing Rufus::Tokyo::Cabinet' do

  it 'should raise an error when opening in read-only mode' do

    lambda {
      Rufus::Tokyo::Cabinet.new('tmp/naidesuyo.tch', :mode => 'r')
    }.should.raise(Rufus::Tokyo::TokyoError).message.should.equal(
      "failed to open/create db 'tmp/naidesuyo.tch#mode=r' {:mode=>\"r\"}")
  end
end

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like "an abstract structure"

  it 'should return its path' do

    @db.path.should.equal('tmp/cabinet_spec.tch')
  end

  it 'should create its underlying file' do

    File.exist?('tmp/cabinet_spec.tch').should.equal(true)
  end
end

describe Rufus::Tokyo::Cabinet do

  before do
    @n = 50
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
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

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure with transactions'
end

describe Rufus::Tokyo::Cabinet do

  it 'should accept a default value' do

    cab = Rufus::Tokyo::Cabinet.new(
      'tmp/cabinet_spec_default.tch', :default => '@?!')
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
    cab.close
  end

  it 'should accept a default value (later)' do

    cab = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec_default.tch')
    cab.default = '@?!'
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
    cab.close
  end
end

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
    3.times { |i| @db[i.to_s] = "val#{i}" }
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #lget/lput/ldelete'
end

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #add{int|double}'
end

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #putkeep'
  behaves_like 'abstract structure #putcat'
end

describe Rufus::Tokyo::Cabinet do

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

  it 'should respond to defrag (or not) (TC >= 1.4.21)' do

    cab = Rufus::Tokyo::Cabinet.open('tmp/toto.tch')

    if Rufus::Tokyo::CabinetLib.respond_to?(:tctdbsetdfunit)
      cab.defrag
      true.should.equal(true)
    else
      lambda() { cab.defrag }.should.raise(NotImplementedError)
    end

    cab.close
  end
end

describe Rufus::Tokyo::Cabinet do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure flattening keys and values'
end

describe 'Rufus::Tokyo::Cabinet with a default value' do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch', :default => 'Nemo')
    @db.clear
    @db['known'] = 'Ulysse'
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure with a default value'
end

describe 'Rufus::Tokyo::Cabinet with a default_proc' do

  before do
    @db = Rufus::Tokyo::Cabinet.new(
      'tmp/cabinet_spec.tch',
      :default_proc => lambda { |db, k| "default:#{k}" })
    @db.clear
    @db['known'] = 'Ulysse'
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure with a default_proc'
end

