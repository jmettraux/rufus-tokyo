
#
# Specifying rufus-tokyo
#
# Sun Feb  8 16:07:16 JST 2009
#

require File.join(File.dirname(__FILE__), 'spec_base')
require File.join(File.dirname(__FILE__), 'shared_table_spec')

require 'rufus/tokyo'

FileUtils.mkdir('tmp') rescue nil


describe Rufus::Tokyo::Table do

  it 'should open in write/create mode by default' do

    t = Rufus::Tokyo::Table.new('tmp/default.tct')
    t.close
    File.exist?('tmp/default.tct').should.equal(true)
    FileUtils.rm('tmp/default.tct')
  end

  it 'should raise an error when file is missing' do

    lambda {
      Rufus::Tokyo::Table.new('tmp/missing.tct', :mode => 'r')
    }.should.raise(
      Rufus::Tokyo::TokyoError).message.should.equal('(err 3) file not found')
  end
end

describe Rufus::Tokyo::Table do

  before do
    @t = Rufus::Tokyo::Table.new('tmp/table.tct')
    @t.clear
  end
  after do
    @t.close
  end

  it 'should return its path' do

    @t.path.should.equal('tmp/table.tct')
  end

  behaves_like 'table'
end

describe Rufus::Tokyo::Table do

  before do
    @t = Rufus::Tokyo::Table.new('tmp/table.tct')
    @t.clear
  end
  after do
    @t.close
  end

  behaves_like 'table with transactions'
end

describe 'Rufus::Tokyo::Table #keys' do

  before do
    @n = 50
    @t = Rufus::Tokyo::Table.new('tmp/test_new.tct')
    @t.clear
    @n.times { |i| @t["person#{i}"] = { 'name' => 'whoever' } }
    @n.times { |i| @t["animal#{i}"] = { 'name' => 'whichever' } }
    @t["toto#{0.chr}5"] = { 'name' => 'toto' }
  end
  after do
    @t.close
  end

  behaves_like 'table #keys'
end

def prepare_table_with_data

  t = Rufus::Tokyo::Table.new('tmp/test_new.tct')
  t.clear
  t['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
  t['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
  t['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
  t['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
  t
end

describe Rufus::Tokyo::Table do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table indexes'
end

describe 'Rufus::Tokyo::Table#lget' do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table lget'
end

# DONE

describe 'Rufus::Tokyo::Table, like a Ruby Hash' do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table like a hash'
end

describe Rufus::Tokyo::TableQuery do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table query'
end

describe 'Rufus::Tokyo::TableQuery (fts)' do

  before do
    @t = Rufus::Tokyo::Table.new('tmp/test_new.tct')
    @t.clear
    [
      "consul readableness choleric hopperdozer juckies",
      "fume overharshness besprinkler whirling erythrene",
      "trumper defiable detractively cattiness superioress",
      "vivificative consul agglomerated Peterloo way",
      "unkilned bituminate antimatrimonial uran polyphony",
      "kurumaya unannexed renownedly apetaloid consul",
      "overdare nescience seronegative nagster overfatten",
    ].each_with_index { |w, i|
      @t["pk#{i}"] = { 'name' => "lambda#{i}", 'words' => w }
    }
  end
  after do
    @t.close
  end

  behaves_like 'table query (fts)'
end

describe 'Rufus::Tokyo::TableQuery#process' do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table query #process'
end

describe 'results from queries on Rufus::Tokyo::Table' do

  before do
    @t = prepare_table_with_data
  end
  after do
    @t.close
  end

  behaves_like 'table query results'
end

