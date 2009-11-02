
#
# Specifying rufus-tokyo
#
# Tue Jul 21 13:02:53 JST 2009
#


shared 'table' do

  it 'should generate unique ids' do

    @t.genuid.should.satisfy { |i| i.to_s > '0' }
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

  #it 'should raise an ArgumentError on non-string column name' do
  #  lambda {
  #    @t['pk0'] = [ 1, 2 ]
  #  }.should.raise(ArgumentError)
  #  lambda {
  #    @t['pk0'] = { 1 => 2 }
  #  }.should.raise(ArgumentError)
  #end
  #it 'should raise an ArgumentError on non-string column value' do
  #  lambda {
  #    @t['pk0'] = { 'a' => 2 }
  #  }.should.raise(ArgumentError)
  #end

  it 'should store binary data \0' do
    s = "toto#{0.chr}nada"
    @t[s] = { s => s }
    @t[s].should.equal({ s => s })
  end

  it 'should stringify primary key, keys, and values on read and write' do
    @t[123] = {:num => 456}
    @t["123".to_sym].should.equal("num" => "456")
  end
end

shared 'table with transactions' do

  it 'should correctly abort transactions' do

    @t.transaction {
      @t['pk0'] = { 'a' => 'A' }
      @t.abort
    }
    @t.size.should.be.zero
  end

  it 'should rollback transactions with errors, and bubble exceptions' do

    begin
      @t.transaction {
        @t['pk0'] = { 'a' => 'A' }
        raise 'something goes wrong'
      }
    rescue RuntimeError
    end
    @t.size.should.be.zero
  end

  it 'should rollback transactions with Abort exceptions, and consume exceptions' do

    @t.transaction {
      @t['pk0'] = { 'a' => 'A' }
      raise Rufus::Tokyo::Transactions::Abort
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
end

shared 'table #keys' do

  it 'should return a Ruby Array by default' do

    @t.keys.class.should.equal(::Array)
  end

  if @t.class.name.match(/^Rufus::Tokyo/)

    it 'should return a Cabinet List when :native => true' do

      l = @t.keys(:native => true)
      l.class.should.equal(Rufus::Tokyo::List)
      l.size.should.equal(2 * @n + 1)
      l.free
    end
  end

  it 'should retrieve forward matching keys when :prefix => "prefix-"' do

    @t.keys(:prefix => 'person').size.should.equal(@n)

    #l = @t.keys(:prefix => 'animal', :native => true)
    #l.size.should.equal(@n)
    #l.free
    l = @t.keys(:prefix => 'animal')
    l.size.should.equal(@n)
  end

  it 'should retrieve keys that contain \0' do

    @t.keys.include?("toto#{0.chr}5").should.be.true
  end

  it 'should retrieve forward matching keys when key contains \0' do

    @t.keys(:prefix => 'toto').should.equal([ "toto#{0.chr}5" ])
  end

  it 'should return a limited number of keys when :limit is set' do

    @t.keys(:limit => 20).size.should.equal(20)
  end

  it 'should delete_keys_with_prefix' do

    @t.delete_keys_with_prefix('animal')
    @t.size.should.equal(@n + 1)
    @t.keys(:prefix => 'animal').size.should.equal(0)
  end
end

shared 'table indexes' do

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

shared 'table lget' do

  it 'should return an empty hash for missing keys' do
    @t.lget(%w{ pk97 pk98 }).should.equal({})
    @t.mget(%w{ pk97 pk98 }).should.equal({})
  end

  it 'should return multiple records' do
    @t.lget(%w{ pk0 pk1 }).should.equal({
      'pk0' => { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' },
      'pk1' => { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
    })
    @t.lget(*%w{ pk0 pk1 }).should.equal({
      'pk0' => { 'name' => 'jim', 'age' => '25', 'lang' => 'ja,en' },
      'pk1' => { 'name' => 'jeff', 'age' => '32', 'lang' => 'en,es' }
    })
  end
end

shared 'table like a hash' do

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

shared 'table query' do

  it 'can be executed' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
    }.size.should.equal(4)
  end

  if @t.class.name.match(/^Rufus::Tokyo::/)

    it 'can be prepared' do

      @t.prepare_query { |q|
        q.add 'lang', :includes, 'en'
      }.should.satisfy { |q| q.class == Rufus::Tokyo::TableQuery }
    end
  end

  it 'can be counted' do

    q = @t.prepare_query { |qq| qq.add 'lang', :includes, 'en' }
    q.run
    q.count.should.equal(4)
  end

  it 'can be counted without being explicitly run' do

    @t.prepare_query { |qq|
      qq.add 'lang', :includes, 'en'
    }.count.should.equal(4)
  end

  it 'can be counted immediately (qrycount table#query_count)' do

    @t.query_count { |qq|
      qq.add 'lang', :includes, 'en'
    }.should.equal(4)
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

  if (@t.respond_to?(:lib) && @t.lib.respond_to?(:qry_setlimit)) ||
     (defined?(TokyoCabinet) && TokyoCabinet::TDBQRY.public_instance_methods.collect { |e| e.to_s }.include?('setlimit'))

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

shared 'table query (fts)' do

  it 'can do full-text search' do

    @t.query { |q|
      q.add 'words', :ftsphrase, 'consul'
      q.pk_only
    }.to_a.should.equal(%w[ pk0 pk3 pk5 ])
  end
end

shared 'table query #process' do

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

shared 'table query results' do

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

shared 'tyrant table with embedded lua' do

  it 'should call Lua extensions' do
    @t.ext(:hi).should.equal('Hi!')
  end

  it 'should return nil when function is missing' do
    @t.ext(:missing, 'nada', 'forever').should.equal(nil)
  end
end

shared 'a table structure flattening keys and values' do

  it 'should to_s column names when #set_index' do

    @t.set_index(:name, :lexical).should.equal(true)
  end

  it 'should to_s keys and values in the hash when #[]=' do

    @t[:toto] = { :a => 1, :b => 2 }
    @t['toto'].should.equal({ 'a' => '1', 'b' => '2' })
  end

  it 'should to_s keys when #delete' do

    @t['toto'] = { 'a' => '1', 'b' => '2' }
    @t.delete(:toto).should.equal({ 'a' => '1', 'b' => '2' })
  end

  it 'should to_s keys when #lget' do

    (1..7).each { |i| @t["toto#{i}"] = { 'i' => i.to_s } }

    @t.lget([ :toto1, :toto3, :toto4 ]).should.equal(
      {"toto1"=>{"i"=>"1"}, "toto3"=>{"i"=>"3"}, "toto4"=>{"i"=>"4"}})
  end
end

shared 'a table structure to_s-ing query stuff' do

  it 'should accept symbols as column names' do

    @t.query { |q|
      q.add :lang, :includes, 'en'
    }.size.should.equal(4)
  end

  it 'should accept non-strings as values' do

    @t.query { |q|
      q.add 'age', :equals, 44
    }.to_a.should.equal(
      [{"name"=>"jack", "lang"=>"en", :pk=>"pk2", "age"=>"44"}])
  end

  it 'should accept symbols as column names in #order_by' do

    @t.query { |q|
      q.add 'lang', :includes, 'en'
      q.order_by :name, :desc
      q.limit 2
    }.to_a.should.equal([
      {:pk => 'pk0', "name"=>"jim", "lang"=>"ja,en", "age"=>"25"},
      {:pk => 'pk1', "name"=>"jeff", "lang"=>"en,es", "age"=>"32"}])
  end
end

shared 'table query metasearch' do

  it 'can do UNION on queries' do

    @t.union(
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'es'
      },
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'li'
      },
      false
    ).should.equal([
      'pk1', 'pk3'
    ])
  end

  it 'can do UNION on queries (and fetch the results)' do

    @t.union(
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'es'
      },
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'li'
      }
    ).should.equal(
      {"pk1"=>{"name"=>"jeff", "lang"=>"en,es", "age"=>"32"}, "pk3"=>{"name"=>"jake", "lang"=>"en,li", "age"=>"45"}}
    )
  end

  it 'can do INTERSECTION on queries' do

    @t.intersection(
      @t.prepare_query { |q|
        q.add 'age', :gt, '30'
      },
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'li'
      },
      false
    ).should.equal([
      'pk3'
    ])
  end

  it 'can do DIFFERENCE on queries' do

    @t.difference(
      @t.prepare_query { |q|
        q.add 'age', :gt, '30'
      },
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'li'
      },
      false
    ).should.equal([
      'pk1', 'pk2'
    ])
  end

  it 'can do meta with only one query' do

    @t.difference(
      @t.prepare_query { |q|
        q.add 'age', :gt, '30'
      },
      false
    ).should.equal([
      'pk1', 'pk2', 'pk3'
    ])
  end

  it 'should complain when there is no query' do

    lambda {
      @t.difference(false)
    }.should.raise(ArgumentError)
  end

  it 'can do metasearch a la ruby-tokyotyrant' do

    @t.search(
      :difference,
      @t.prepare_query { |q|
        q.add 'age', :gt, '30'
      },
      @t.prepare_query { |q|
        q.add 'lang', :includes, 'li'
      }
    ).should.equal(
      {"pk1"=>{"name"=>"jeff", "lang"=>"en,es", "age"=>"32"}, "pk2"=>{"name"=>"jack", "lang"=>"en", "age"=>"44"}}
    )
  end
end

