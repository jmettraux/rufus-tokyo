
#
# Specifying rufus-tokyo
#
# Sun Feb  8 16:07:16 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'fileutils'
require 'rufus/tokyo/cabinet/table'


describe 'a Tokyo Cabinet table' do

  before do
    FileUtils.mkdir('tmp') rescue nil
  end

  it 'should open in write/create mode by default' do

    t = Rufus::Tokyo::Table.new('tmp/default.tdb')
    t.close
    File.exist?('tmp/default.tdb').should.equal(true)
    FileUtils.rm('tmp/default.tdb')
  end

  it 'should raise an error when file is missing' do

    lambda {
      Rufus::Tokyo::Table.new('tmp/missing.tdb', :readonly)
    }.should.raise(
      Rufus::Tokyo::TokyoError).message.should.equal('(err 3) file not found')
  end
end

describe 'a Tokyo Cabinet table' do

  before do
    FileUtils.mkdir('tmp') rescue nil
    @t = Rufus::Tokyo::Table.new('tmp/table.tdb')
    @t.clear
  end
  after do
    @t.close
  end

  it 'should generate unique ids' do

    @t.genuid.should.satisfy { |i| i > 0 }
  end

  it 'should return nil for missing keys' do

    @t['missing'].should.be.nil
  end

  it 'should accept tabbed and map input' do

    @t.size.should.equal(0)
    @t.tabbed_put('pk0', 'name', 'toto', 'age', '30')
    @t['pk1'] = { 'name' => 'fred', 'age' => '22' }
    @t.size.should.equal(2)
  end

  it 'should return map values' do

    @t.tabbed_put('pk0', 'name', 'toto', 'age', '30')
    @t['pk0'].should.equal({ 'name' => 'toto', 'age' => '30' })
  end

end

def prepare_table_with_data
  FileUtils.mkdir('tmp') rescue nil
  t = Rufus::Tokyo::Table.new('tmp/test_new.tdb', :create, :write)
  t.clear
  t['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
  t['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
  t['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
  t['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
  t
end

describe 'a Tokyo Cabinet table, like a Ruby Hash,' do

  before do
    @t = prepare_table_with_data
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

describe 'queries on Tokyo Cabinet tables' do

  before do
    @t = prepare_table_with_data
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
    }.should.satisfy { |q| q.class == Rufus::Tokyo::TableQuery }
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

end

describe 'results from Tokyo Cabinet table queries' do

  before do
    @t = prepare_table_with_data
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

