
#
# Specifying rufus-tokyo
#
# Wed Feb 25 10:38:42 JST 2009
#

require File.join(File.dirname(__FILE__), 'spec_base')
require File.join(File.dirname(__FILE__), 'shared_table_spec')
require File.join(File.dirname(__FILE__), 'shared_tyrant_spec')

require 'rufus/edo/ntyrant'


describe 'a missing Rufus::Edo::NetTyrantTable' do

  it 'should raise an error' do

    lambda {
      Rufus::Edo::NetTyrantTable.new('127.0.0.1', 1)
    }.should.raise(Rufus::Edo::EdoError).message.should.equal(
      '(err 3) connection refused')
  end
end

describe 'Rufus::Edo::NetTyrantTable' do

  it 'should refuse to connect to a plain Tyrant' do

    lambda {
      t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45000)
    }.should.raise(ArgumentError)
  end
end

describe 'Rufus::Edo::NetTyrantTable' do

  before do
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
    #puts @t.stat.inject('') { |s, (k, v)| s << "#{k} => #{v}\n" }
    @t.clear
  end
  after do
    @t.close
  end

  it 'should respond to stat' do

    @t.stat['type'].should.equal('table')
  end

  behaves_like 'table'
  behaves_like 'a Tyrant structure (no transactions)'
end

describe Rufus::Edo::NetTyrantTable do

  before do
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  it 'should not support transactions' do
    lambda {
      @t.transaction {}
    }.should.raise(NoMethodError)
    lambda {
      @t.abort
    }.should.raise(NoMethodError)
  end
end

describe 'Rufus::Edo::NetTyrantTable #keys' do

  before do
    @n = 50
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
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

def prepare_table_with_data (port)
  t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', port)
  t.clear
  t['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
  t['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
  t['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
  t['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
  t
end

describe 'a Tokyo Tyrant table' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
    # TODO : well there are trailing indexes now... :(
  end

  behaves_like 'table indexes'
end

describe 'Rufus::Edo::NetTyrantTable#lget' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table lget'
end

describe 'Rufus::Edo::NetTyrantTable, like a Ruby Hash,' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table like a hash'
end

describe 'queries on Rufus::Edo::NetTyrantTable' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query'
end

describe 'Queries on Tokyo Tyrant tables (via Rufus::Edo)' do

  before do
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
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

describe 'Rufus::Edo::NetTyrantTable and TableQuery#process' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  # TODO : orly ?

  it 'should not work' do

    lambda {
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
      }.free
    }.should.raise(NoMethodError)
  end
end

describe 'results from Rufus::Edo::NetTyrantTable queries' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query results'
end

describe 'Rufus::Edo::NetTyrantTable (lua extensions)' do

  before do
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  behaves_like 'tyrant table with embedded lua'
end

describe Rufus::Edo::NetTyrantTable do

  before do
    @t = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
    @t.clear
  end
  after do
    @t.close
  end

  behaves_like 'a table structure flattening keys and values'
end

describe 'Rufus::Edo::NetTyrantTable\'s queries' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'a table structure to_s-ing query stuff'
end

describe 'Rufus::Edo::Table and metasearch' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  behaves_like 'table query metasearch'
end

