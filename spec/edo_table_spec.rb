
#
# Specifying rufus-tokyo
#
# Mon Feb 23 11:11:10 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo'
rescue LoadError
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe 'Rufus::Edo::Table' do

    it 'should open in write/create mode by default' do

      t = Rufus::Edo::Table.new('tmp/default.tct')
      t.close
      File.exist?('tmp/default.tct').should.equal(true)
      FileUtils.rm('tmp/default.tct')
    end

    it 'should raise an error when file is missing' do

      lambda {
        Rufus::Edo::Table.new('tmp/missing.tct', :mode => 'r')
      }.should.raise(
        Rufus::Edo::EdoError).message.should.equal('(err 3) file not found')
    end
  end

  describe 'Rufus::Edo::Table' do

    before do
      @t = Rufus::Edo::Table.new('tmp/table.tct')
      @t.clear
    end
    after do
      @t.close
    end

    it 'should return its path' do

      @t.path.should.equal('tmp/table.tct')
    end

    it 'should generate unique ids' do

      @t.genuid.should.satisfy { |i| i > 0 }
    end

    it 'should return nil for missing keys' do

      @t['missing'].should.be.nil
    end

    it 'should accept Array and Hash input' do

      @t.size.should.equal(0)

      @t['pk0'] = [ 'name', 'toto', 'age', '30' ]
      @t['pk1'] = { 'name' => 'fred', 'age' => '22' }

      @t.size.should.equal(2)
      @t['pk0'].should.equal({ 'name' => 'toto', 'age' => '30' })
    end

    it 'should return nil when deleting inexistent entries' do

      @t.delete('I_do_not_exist').should.equal(nil)
    end

    it 'should delete the entry and return the value' do

      @t['pk0'] = [ 'name', 'toto', 'age', '30' ]
      @t.delete('pk0').should.equal({ 'name' => 'toto', 'age' => '30' })
      @t.size.should.equal(0)
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

    it 'should correctly abort transactions' do

      @t.transaction {
        @t['pk0'] = { 'a' => 'A' }
        @t.abort
      }
      @t.size.should.be.zero
    end

    it 'should rollback transactions with errors' do

      @t.transaction {
        @t['pk0'] = { 'a' => 'A' }
        raise "something goes wrong"
      }
      @t.size.should.be.zero
    end

    it 'should commit successful transactions' do

      @t.transaction do
        @t['pk0'] = { 'a' => 'A' }
      end
      @t['pk0'].should.equal({ 'a' => 'A' })
    end

    it 'should abort low level transactions' do

      @t.tranbegin
      @t['pk0'] = { 'a' => 'A' }
      @t.tranabort
      @t.size.should.be.zero
    end

    it 'should commit low level transactions' do

      @t.tranbegin
      @t['pk0'] = { 'a' => 'A' }
      @t.trancommit
      @t['pk0'].should.equal({ 'a' => 'A' })
    end

    it 'should store binary data \0' do
      s = "toto#{0.chr}nada"
      @t[s] = { s => s }
      @t[s].should.equal({ s => s })
    end

  end


  describe 'Rufus::Edo::Table #keys' do

    before do
      @n = 50
      @tab = Rufus::Edo::Table.new('tmp/test_new.tct')
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


  def prepare_table_with_data

    t = Rufus::Edo::Table.new('tmp/test_new.tct')
    t.clear
    t['pk0'] = { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' }
    t['pk1'] = { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
    t['pk2'] = { 'name' => 'jack', 'age' => '44', 'lang' => 'en' }
    t['pk3'] = { 'name' => 'jake', 'age' => '45', 'lang' => 'en,li' }
    t
  end

  describe 'Rufus::Edo::Table' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
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

  describe 'Rufus::Edo::Table#lget' do

    before do
      @t = prepare_table_with_data
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

  describe 'Rufus::Edo::Table, like a Ruby Hash,' do

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

  describe 'queries on Rufus::Edo::Table' do

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
      }.should.satisfy { |q| q.class == Rufus::Edo::TableQuery }
    end

    it 'can be counted' do
      # testing the mimicking the count function of TC 1.4.21

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

    if TokyoCabinet::TDBQRY.public_instance_methods.collect { |e|
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

  describe 'Rufus::Tokyo::TableQuery#process' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    it 'can iterate over the matching records' do

      keys, values = [], []

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
        keys << k
        values << v
      }.free

      keys.should.equal(%w[ pk0 pk1 pk2 pk3 ])
      values.first.keys.sort.should.equal(%w[ age lang name ])
    end

    it 'can stop while iterating' do

      seen = 0

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
        seen = seen + 1
        :stop
      }.free

      seen.should.equal(1)
    end

    it 'can delete while iterating' do

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
        v['name'].match(/^ja/) ? :delete : nil
      }.free

      @t.keys.sort.should.equal(%w[ pk0 pk1 ])
    end

    it 'can update while iterating' do

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.process { |k, v|
        v['name'].match(/^ja/) ? v.merge('special' => 'seen') : nil
      }.free

      @t.size.should.equal(4)

      @t['pk2'].should.equal(
        {'name'=>'jack', 'age'=>'44', 'lang'=>'en', 'special'=>'seen'})
      @t['pk3'].should.equal(
        {'name'=>'jake', 'age'=>'45', 'lang'=>'en,li', 'special'=>'seen'})
    end

    it 'can update, delete and stop' do

      seen = []

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
        q.order_by 'name', :desc
      }.process { |k, v|
        seen << v['name']
        case v['name']
        when 'jim' then nil
        when 'jeff' then :delete
        when 'jake' then [ :stop, v.merge('special' => 'nada') ]
        end
      }.free

      seen.include?('jack').should.be.false

      @t.size.should.equal(3)

      @t['pk3'].should.equal(
        {'name'=>'jake', 'age'=>'45', 'lang'=>'en,li', 'special'=>'nada'})
      @t['pk1'].should.be.nil
    end
  end

  describe 'results from Rufus::Edo::Table queries' do

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
end

