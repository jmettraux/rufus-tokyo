
#
# Specifying rufus-tokyo
#
# Sat Feb 21 22:16:23 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'
require File.dirname(__FILE__) + '/shared_abstract_spec'

begin
  require 'rufus/edo'
rescue LoadError
  puts "'TokyoCabinet' ruby bindings not available on this ruby platform"
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil

  describe 'a missing Rufus::Edo::Cabinet' do

    it 'should raise an error' do

      lambda {
        Rufus::Edo::Cabinet.new('tmp/naidesuyo.tch', :mode => 'r')
      }.should.raise(Rufus::Edo::EdoError).message.should.equal(
        '(err 3) file not found')
    end
  end

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch')
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like "an abstract structure"

    it 'should return its path' do

      @db.path.should.equal('tmp/edo_cabinet_spec.tch')
    end

    it 'should create its underlying file' do

      File.exist?('tmp/cabinet_spec.tch').should.equal(true)
    end
  end

  describe 'Rufus::Edo::Cabinet #keys' do

    before do
      @n = 50
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
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

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_tran_spec.tch')
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure with transactions'
  end

  describe Rufus::Edo::Cabinet do

    it 'should accept a default value' do

      cab = Rufus::Edo::Cabinet.new(
        'tmp/cabinet_spec_default.tch', :default => '@?!')
      cab['a'] = 'A'
      cab.size.should.equal(1)
      cab['b'].should.equal('@?!')
      cab.close
    end

    it 'should accept a default value (later)' do

      cab = Rufus::Edo::Cabinet.new('tmp/cabinet_spec_default.tch')
      cab.default = '@?!'
      cab['a'] = 'A'
      cab.size.should.equal(1)
      cab['b'].should.equal('@?!')
      cab.close
    end
  end

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch')
      #@db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch', :type => :abstract)
      @db.clear
      3.times { |i| @db[i.to_s] = "val#{i}" }
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #lget/lput/ldelete'
  end

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #add{int|double}'
  end

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch')
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'abstract structure #putkeep'
    behaves_like 'abstract structure #putcat'
  end

  describe Rufus::Edo::Cabinet do

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
        :result
      end

      res.should.equal(:result)

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

  describe Rufus::Edo::Cabinet do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_spec.tch')
      @db.clear
    end
    after do
      @db.close
    end

    behaves_like 'an abstract structure flattening keys and values'
  end

  describe 'Rufus::Edo::Cabinet with a default value' do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_spec.tch', :default => 'Nemo')
      @db.clear
      @db['known'] = 'Ulysse'
    end
    after do
      @db.close
    end

    behaves_like 'an abstract structure with a default value'
  end

  describe 'Rufus::Edo::Cabinet with a default_proc' do

    before do
      @db = Rufus::Edo::Cabinet.new(
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
end

