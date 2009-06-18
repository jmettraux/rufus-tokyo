
#
# Specifying rufus-tokyo
#
# Wed Feb 25 10:38:42 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/edo/ntyrant'


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

  it 'should generate unique ids' do

    @t.genuid.should.satisfy { |i| i.to_i > 0 }
  end

  it 'should clear db' do

    @t.clear
    @t.size.should.be.zero
  end

  it 'should return nil for missing keys' do

    @t['missing'].should.be.nil
  end

  it 'should accept map input' do

    @t['pk0'] = value = { 'name' => 'fred', 'age' => '22' }
    @t['pk0'].should.equal(value)
  end

  it 'should raise an ArgumentError on non map or hash input' do

    lambda {
      @t['pk0'] = 'bad thing here'
    }.should.raise(ArgumentError)
  end

  it 'should raise an ArgumentError on non-string column name' do

    lambda {
      @t['pk0'] = [ 1, 2 ]
    }.should.raise(ArgumentError)
    lambda {
      @t['pk0'] = { 1 => 2 }
    }.should.raise(ArgumentError)
  end

  it 'should raise an ArgumentError on non-string column value' do

    lambda {
      @t['pk0'] = { 'a' => 2 }
    }.should.raise(ArgumentError)
  end

  it 'should return map values' do

    @t['pk0'] = { 'name' => 'toto', 'age' => '30' }
    @t['pk0'].should.equal({ 'name' => 'toto', 'age' => '30' })
  end

  it 'should delete records' do

    @t['pk0'] = { 'name' => 'toto', 'age' => '30' }
    @t.delete('pk0')
    @t['pk0'].should.be.nil
  end

  it 'should return deleted value' do

    @t['pk0'] = old = { 'name' => 'toto', 'age' => '30' }
    @t.delete('pk0').should.equal(old)
  end

  it 'should change store size after deleting' do

    @t['pk0'] = { 'name' => 'toto', 'age' => '30' }
    @t.delete('pk0')
    @t.size.should.be.zero
  end

  it 'should not support transactions' do
    lambda {
      @t.transaction {}
    }.should.raise(NoMethodError)
    lambda {
      @t.abort
    }.should.raise(NoMethodError)
  end

  it 'should store binary data \0' do
    s = "toto#{0.chr}nada"
    @t[s] = { s => s }
    @t[s].should.equal({ s => s })
  end

end


describe 'Rufus::Edo::NetTyrantTable #keys' do

  before do
    @n = 50
    @tab = Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001)
    @tab.clear
    @n.times { |i| @tab["person#{i}"] = { 'name' => 'whoever' } }
    @n.times { |i| @tab["animal#{i}"] = { 'name' => 'whichever' } }
    @tab["toto#{0.chr}5"] = { 'name' => 'toto' }
  end

  after do
    @tab.close
  end

  it 'should return a Ruby Array by default' do

    @tab.keys.class.should.equal(::Array)
  end

  it 'should retrieve forward matching keys when :prefix => "prefix-"' do

    @tab.keys(:prefix => 'person').size.should.equal(@n)
  end

  it 'should retrieve keys that contain \0' do

    @tab.keys.include?("toto#{0.chr}5").should.be.true
  end

  it 'should retrieve forward matching keys when key contains \0' do

    @tab.keys(:prefix => 'toto').should.equal([ "toto#{0.chr}5" ])
  end

  it 'should return a limited number of keys when :limit is set' do

    @tab.keys(:limit => 20).size.should.equal(20)
  end

  it 'should delete_keys_with_prefix' do

    @tab.delete_keys_with_prefix('animal')
    @tab.size.should.equal(@n + 1)
    @tab.keys(:prefix => 'animal').size.should.equal(0)
  end
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

  it 'should accept lexical indexes' do
    @t.set_index('name', :lexical).should.equal(true)
  end

  it 'should accept decimal indexes' do
    @t.set_index('age', :decimal).should.equal(true)
  end

  it 'should accept removal of indexes' do
    @t.set_index('age', :decimal)
    @t.set_index('age', :remove).should.equal(true)
  end

  it 'should accept indexes on the primary key (well...)' do
    @t.set_index(:pk, :lexical).should.equal(true)
    @t.set_index('', :lexical).should.equal(true)
  end
end


describe 'Rufus::Edo::NetTyrantTable#lget' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  it 'should return an empty hash for missing keys' do
    @t.lget(%w{ pk97 pk98 }).should.equal({})
  end

  it 'should return multiple records' do
    @t.lget(%w{ pk0 pk1 }).should.equal({
      'pk0' => { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' },
      'pk1' => { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
    })
  end
end


describe 'Rufus::Edo::NetTyrantTable, like a Ruby Hash,' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  it 'should respond to #keys' do

    @t.keys.should.equal([ 'pk0', 'pk1', 'pk2', 'pk3' ])
  end

  it 'should respond to #values' do

    @t.values.should.equal([
      { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' },
      { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' },
      { 'name' => 'jack', 'age' => '44', 'lang' => 'en' },
      { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }])
  end

  it 'should benefit from Enumerable' do

    @t.find { |k, v|
      v['name'] == 'jeff'
    }.should.equal([
      'pk1', { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }])
  end
end


describe 'queries on Rufus::Edo::NetTyrantTable' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

  it 'can be executed' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
    }.size.should.equal(4)
  end

  it 'can be prepared' do

    @t.prepare_query { |q|
      q.add 'lang', :includes, 'en'
    }.should.satisfy { |q| q.class == Rufus::Edo::TableQuery }
  end

  it 'can be counted' do
    # testing the mimicking the count function of TT 1.1.19

    q = @t.prepare_query { |q|
      q.add 'lang', :includes, 'en'
    }
    q.run
    q.count.should.equal(4)
  end

  it 'can be limited' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
      q.limit 2
    }.size.should.equal(2)
  end

  it 'can leverage regex matches' do

    @t.query { |q|
      q.add 'name', :matches, '^j.+k'
    }.to_a.should.equal([
      {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
      {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"}])
  end

  it 'can leverage numerical comparison (gt)' do

    @t.query { |q|
      q.add 'age', :gt, '40'
      q.pk_only
    }.to_a.should.equal([ 'pk2', 'pk3' ])
  end

  it 'can have negated conditions' do

    @t.query { |q|
      q.add 'age', :gt, '40', false
      q.pk_only
    }.to_a.should.equal([ 'pk0', 'pk1' ])
  end

  if TokyoTyrant::RDBQRY.public_instance_methods.collect { |e|
    e.to_s }.include?('setlimit')

    it 'can be limited and have an offset' do

      @t.query { |q|
        q.add 'lang', :includes, 'en'
        q.order_by 'name', :desc
        q.limit 2, 0
      }.collect { |e| e['name'] }.should.equal(%w{ jim jeff })
      @t.query { |q|
        q.add 'lang', :includes, 'en'
        q.order_by 'name', :desc
        q.limit 2, 2
      }.collect { |e| e['name'] }.should.equal(%w{ jake jack })
    end
  end

  it 'can be deleted (searchout : query#delete)' do

    @t.prepare_query { |q|
      q.add 'lang', :includes, 'es'
    }.delete

    @t.size.should.equal(3)
  end

  it 'can be deleted immediately (searchout table#query_delete)' do

    @t.query_delete { |q|
      q.add 'lang', :includes, 'es'
    }

    @t.size.should.equal(3)
  end
end

describe 'Tokyo Tyrant and TableQuery#process' do

  before do
    @t = prepare_table_with_data(45001)
  end
  after do
    @t.close
  end

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

  it 'can come ordered (strdesc)' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
      q.order_by 'name', :desc
      q.limit 2
    }.to_a.should.equal([
      {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
      {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"}])
  end

  it 'can come ordered (strasc)' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
      q.order_by 'name', :asc
    }.to_a.should.equal([
      {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
      {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"},
      {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"},
      {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"}])
  end

  it 'can come ordered (numasc)' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
      q.order_by 'age', :numasc
    }.to_a.should.equal([
      {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
      {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"},
      {:pk => 'pk2', "name"=>"jack", "lang"=>"en", "age"=>"44"},
      {:pk => 'pk3', "name"=>"jake", "lang"=>"en,li", "age"=>"45"}])
  end

  it 'can come without the primary keys (no_pk)' do

    @t.query { |q|
      q.add 'name', :matches, '^j.+k'
      q.no_pk
    }.to_a.should.equal([
      {"name"=>"jack", "lang"=>"en", "age"=>"44"},
      {"name"=>"jake", "lang"=>"en,li", "age"=>"45"}])
  end

  it 'can consist only of the primary keys (pk_only)' do

    @t.query { |q|
      q.add 'name', :matches, '^j.+k'
      q.pk_only
    }.to_a.should.equal(["pk2", "pk3"])
  end

end

