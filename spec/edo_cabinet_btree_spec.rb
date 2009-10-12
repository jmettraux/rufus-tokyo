
#
# Specifying rufus-tokyo
#
# Fri Aug 28 08:58:37 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo'
rescue LoadError
  puts "'TokyoCabinet' ruby bindings not available on this ruby platform"
end

DB_FILE = "tmp/edo_cabinet_btree_spec.tcb"

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe 'Rufus::Edo::Cabinet .tcb' do

    before do
      FileUtils.rm(DB_FILE) if File.exist? DB_FILE
      @db = Rufus::Edo::Cabinet.new(DB_FILE)
    end
    after do
      @db.close
    end

    it 'should accept duplicate values' do

      @db.putdup('a', 'a0')
      @db.putdup('a', 'a1')

      @db.getdup('a').should.equal([ 'a0', 'a1' ])
    end
    
    it 'should be able to fetch keys for duplicate values' do
      [ %w[John  Hornbeck],
        %w[Tim   Gourley],
        %w[Grant Schofield],
        %w[James Gray],
        %w[Dana  Gray] ].each do |first, last|
        @db.putdup(last, first)
      end
      @db.keys.should.equal(%w[Gourley Gray Hornbeck Schofield])
      @db.keys(:prefix => "G").should.equal(%w[Gourley Gray])
    end
  end

  describe 'Rufus::Edo::Cabinet .tcb methods' do

    it 'should fail on other structures' do

      @db = Rufus::Edo::Cabinet.new(DB_FILE.sub(/\.tcb\z/, ".tch"))

      lambda { @db.putdup('a', 'a0') }.should.raise(NoMethodError)

      @db.close
    end
  end

  describe 'Rufus::Edo::Cabinet .tcb order' do
    
    before do
      FileUtils.rm(DB_FILE) if File.exist? DB_FILE
    end
    
    it 'should default to a lexical order' do

      db = Rufus::Edo::Cabinet.new(DB_FILE)
      fields = [1, 2, 10, 11, 20, 21]
      fields.each do |n|
        db[n] = n
      end
      db.keys.should.equal(fields.map { |n| n.to_s }.sort)
      db.close
    end

    it 'should allow an explicit :cmpfunc => :lexical' do

      db = Rufus::Edo::Cabinet.new(DB_FILE, :cmpfunc => :lexical)
      fields = [1, 2, 10, 11, 20, 21]
      fields.each do |n|
        db[n] = n
      end
      db.keys.should.equal(fields.map { |n| n.to_s }.sort)
      db.close
    end

    it 'should allow a :cmpfunc => :decimal' do

      db = Rufus::Edo::Cabinet.new(DB_FILE, :cmpfunc => :decimal)
      fields = [1, 2, 10, 11, 20, 21]
      fields.each do |n|
        db[n] = n
      end
      db.keys.should.equal(fields.sort.map { |n| n.to_s })
      db.close
    end

    it 'should allow a custom :cmpfunc as a Proc' do

      db = Rufus::Edo::Cabinet.new(
             DB_FILE,
             :cmpfunc => lambda { |a, b| [a.size, a] <=> [b.size, b] }
      )
      db["one"]   = 1
      db["two"]   = 2
      db["three"] = 3
      db["four"]  = 4
      db["five"]  = 5
      db.to_a.should.equal( [ %w[one 1],  %w[two 2],
                              %w[five 5], %w[four 4],
                              %w[three 3] ] )
      db.close
    end
  end
end

