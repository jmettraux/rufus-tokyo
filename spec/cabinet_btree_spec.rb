
#
# Specifying rufus-tokyo
#
# Fri Aug 28 08:58:37 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'

FileUtils.mkdir('tmp') rescue nil

DB_FILE = "tmp/cabinet_btree_spec.tcb"


describe 'Rufus::Tokyo::Cabinet .tcb' do

  before do
    FileUtils.rm(DB_FILE) if File.exist? DB_FILE
    @db = Rufus::Tokyo::Cabinet.new(DB_FILE)
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

describe 'Rufus::Tokyo::Cabinet .tcb methods' do

  it 'should fail on other structures' do

    @db = Rufus::Tokyo::Cabinet.new(DB_FILE.sub(/\.tcb\z/, ".tch"))

    lambda { @db.putdup('a', 'a0') }.should.raise(NoMethodError)

    @db.close
  end
end

describe 'Rufus::Tokyo::Cabinet .tcb order' do
  
  before do
    FileUtils.rm(DB_FILE) if File.exist? DB_FILE
  end
  
  it 'should default to a lexical order' do

    db = Rufus::Tokyo::Cabinet.new(DB_FILE)
    fields = [1, 2, 10, 11, 20, 21]
    fields.each do |n|
      db[n] = n
    end
    db.keys.should.equal(fields.map { |n| n.to_s }.sort)
    db.close
  end

  it 'should allow an explicit :cmpfunc => :lexical' do

    db = Rufus::Tokyo::Cabinet.new(DB_FILE, :cmpfunc => :lexical)
    fields = [1, 2, 10, 11, 20, 21]
    fields.each do |n|
      db[n] = n
    end
    db.keys.should.equal(fields.map { |n| n.to_s }.sort)
    db.close
  end

  # 
  # It's not possible to call tcbdbsetcmpfunc() through the abstract API, so
  # changing comparison functions are only supported through the Edo interface.
  # 
end
