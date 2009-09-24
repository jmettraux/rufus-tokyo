
#
# Specifying rufus-tokyo
#
# Fri Jul 17 15:37:16 JST 2009 #rubykaigi2009
#

shared 'an abstract structure' do

  it 'should be empty initially' do

    @db.size.should.equal(0)
    @db['pillow'].should.be.nil
  end

  it 'should accept values' do

    @db['pillow'] = 'Shonagon'
    @db.size.should.equal(1)
  end

  it 'should restitute values' do

    @db['pillow'] = 'Shonagon'
    @db['pillow'].should.equal('Shonagon')
  end

  it 'should delete values' do

    @db['pillow'] = 'Shonagon'
    @db.delete('pillow').should.equal('Shonagon')
    @db.size.should.equal(0)
  end

  it 'should accept and restitute \\0 strings' do

    s = "toto#{0.chr}nada"
    @db[s] = s
    @db[s].should.equal(s)
  end

  it 'should reply to #keys and #values' do

    keys = %w{ alpha bravo charly delta echo foxtrott }
    keys.each_with_index { |k, i| @db[k] = i.to_s }
    @db.keys.should.equal(keys)
    @db.values.should.equal(%w{ 0 1 2 3 4 5 })
  end

  it 'should reply to #keys when there are keys containing \0' do

    s = "toto#{0.chr}nada"
    @db[s] = s
    @db.keys.should.equal([ s ])
  end

  it 'should return a Ruby hash on merge' do

    @db['a'] = 'A'

    @db.merge({ 'b' => 'B', 'c' => 'C' }).should.equal(
      { 'a' => 'A', 'b' => 'B', 'c' => 'C' })

    @db['b'].should.be.nil

    @db.size.should.equal(1)
  end

  it 'should have more values in case of merge!' do

    @db['a'] = 'A'

    @db.merge!({ 'b' => 'B', 'c' => 'C' })

    @db.size.should.equal(3)
    @db['b'].should.equal('B')
  end
end

shared 'abstract structure #keys' do

  it 'should return a Ruby Array by default' do

    @db.keys.class.should.equal(::Array)
  end

  it 'should retrieve keys that contain \0' do

    @db.keys.include?("toto#{0.chr}5").should.be.true
  end

  it 'should retrieve forward matching keys when key contains \0' do

    @db.keys(:prefix => 'toto').should.equal([ "toto#{0.chr}5" ])
  end

  it 'should return a limited number of keys when :limit is set' do

    @db.keys(:limit => 20).size.should.equal(20)
  end

  it 'should delete_keys_with_prefix' do

    @db.delete_keys_with_prefix('animal')
    @db.size.should.equal(@n + 1)
    @db.keys(:prefix => 'animal').size.should.equal(0)
  end

  unless @db.class.name.match(/^Rufus::Edo/)

    it 'should return a Cabinet List when :native => true' do

      l = @db.keys(:native => true)
      l.class.should.equal(Rufus::Tokyo::List)
      l.size.should.equal(2 * @n + 1)
      l.free
    end

    it 'should retrieve forward matching keys when :prefix => "prefix-"' do

      @db.keys(:prefix => 'person').size.should.equal(@n)

      l = @db.keys(:prefix => 'animal', :native => true)
      l.size.should.equal(@n)
      l.free
    end
  end
end

shared 'abstract structure with transactions' do

  #before do
  #  @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_spec.tch')
  #  @db.clear
  #end
  #after do
  #  @db.close
  #end

  it 'should correctly abort transactions' do

    @db.transaction {
      @db['pk0'] = 'value0'
      @db.abort
    }
    @db.size.should.be.zero
  end

  it 'should rollback transactions with errors, and bubble exceptions' do

    begin
      @db.transaction {
        @db['pk0'] = 'value0'
        raise 'something goes wrong'
      }
    rescue RuntimeError
    end
    @db.size.should.be.zero
  end

  it 'should rollback transactions with Abort exceptions, and consume exceptions' do

    @db.transaction {
      @db['pk0'] = 'value0'
      raise Rufus::Tokyo::Transactions::Abort
    }
    @db.size.should.be.zero
  end

  it 'should commit successful transactions' do

    @db.transaction do
      @db['pk0'] = 'showanojidaietaminamishima'
    end
    @db['pk0'].should.equal('showanojidaietaminamishima')
  end

  it 'should abort low level transactions' do

    @db.tranbegin
    @db['pk0'] = 'shikataganai'
    @db.tranabort
    @db.size.should.be.zero
  end

  it 'should commit low level transactions' do

    @db.tranbegin
    @db['pk0'] = 'shikataganai'
    @db.trancommit
    @db['pk0'].should.equal('shikataganai')
  end
end

shared 'abstract structure #lget/lput/ldelete' do

  it 'should get multiple values' do

    @db.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1", "2"=>"val2"})
    @db.mget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1", "2"=>"val2"})
    @db.mget(*%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1", "2"=>"val2"})
  end

  it 'should put multiple values' do

    @db.lput('3' => 'val3', '4' => 'val4')
    @db.lget(%w{ 2 3 }).should.equal({"2"=>"val2", "3"=>"val3"})
  end

  it 'should delete multiple values' do

    @db.ldelete(%w{ 2 3 })
    @db.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1"})
  end

  it 'should delete multiple values' do

    @db.ldelete(*%w{ 2 3 })
    @db.lget(%w{ 0 1 2 }).should.equal({"0"=>"val0", "1"=>"val1"})
  end
end

shared 'abstract structure #add{int|double}' do

  it 'should increment (int)' do

    @db.addint('counter', 1).should.equal(1)
    @db.incr('counter', 1).should.equal(2)
    @db.addint('counter', 2).should.equal(4)
    @db.incr('counter').should.equal(5)
  end

  it 'should fail gracefully if counter has already a [string] value (int)' do

    @db['counter'] = 'a'

    lambda { @db.addint('counter', 1) }.should.raise(
      @db.class.name.match(/^Rufus::Edo/) ?
        Rufus::Edo::EdoError : Rufus::Tokyo::TokyoError)

    @db['counter'].should.equal('a')
  end

  it 'should increment (double)' do

    @db.adddouble('counter', 1.0).should.equal(1.0)
    @db.incr('counter', 1.5).should.equal(2.5)
    @db.adddouble('counter', 2.2).should.equal(4.7)
  end

  it 'should fail gracefully if counter has already a [string] value (double)' do

    @db['counter'] = 'a'

    lambda {
      @db.adddouble('counter', 1.0)
    }.should.raise(
      @db.class.name.match(/^Rufus::Edo/) ?
        Rufus::Edo::EdoError : Rufus::Tokyo::TokyoError)

    @db['counter'].should.equal('a')
  end
end

shared 'abstract structure #putkeep' do

  it 'should accept values' do

    @db.putkeep('pillow', 'Shonagon')
    @db.size.should.equal(1)
  end

  it 'should restitute values' do

    @db.putkeep('pillow', 'Shonagon')
    @db['pillow'].should.equal('Shonagon')
  end

  it 'should not overwrite values if already set' do

    @db['pillow'] = 'Shonagon'
    @db['pillow'].should.equal('Shonagon')

    @db.putkeep('pillow', 'Ruby')
    @db['pillow'].should.equal('Shonagon')
  end

  it 'should return true if not yet set' do

    @db.putkeep('pillow', 'Shonagon').should.equal(true)
  end

  it 'should return false if already set' do

    @db['pillow'] = 'Shonagon'
    @db.putkeep('pillow', 'Ruby').should.equal(false)
  end

  it 'should accept binary data \0' do

    s = "Sei#{0.chr}Shonagon"

    @db.putkeep(s, s).should.be.true
    @db[s].should.equal(s)
  end
end

shared 'abstract structure #putcat' do

  it 'should append' do

    @db['heian'] = 'Shonagon'
    @db.putcat('heian', ', Shikibu')
    @db.putcat('heian', ', Michitsuna')

    @db['heian'].should.equal('Shonagon, Shikibu, Michitsuna')
  end

  it 'should create when not present' do

    @db.putcat('regent', 'Fujiwara no Michinaga')

    @db['regent'].should.equal('Fujiwara no Michinaga')
  end
end

shared 'tyrant with embedded lua' do

  it 'should call lua extensions' do

    @db['toto'] = '0'
    3.times { @db.ext(:incr, 'toto', '1') }
    @db.ext('incr', 'toto', 2) # lax

    @db['toto'].should.equal('5')
  end

  it 'should return nil when function is missing' do

    @db.ext(:missing, 'nada', 'forever').should.equal(nil)
  end
end

shared 'an abstract structure flattening keys and values' do

  it 'should to_s keys and values when #[]=' do

    @db[:hello] = :world
    @db['hello'].should.equal('world')
    @db[:hello].should.equal('world')
    @db.size.should.equal(1)
  end

  it 'should to_s keys and values when #putkeep' do

    @db.putkeep(:pillow, :shonagon)
    @db[:pillow].should.equal('shonagon')
    @db.size.should.equal(1)
  end

  it 'should to_s keys when #delete' do

    @db['hello'] = 'world'
    @db.delete(:hello).should.equal('world')
    @db.size.should.equal(0)
  end

  it 'should to_s keys when #lget' do

    writers = %w[ shikibu shonagon ]
    writers.each { |s| @db[s] = s }
    @db.lget(writers.collect { |w| w.to_sym }).keys.sort.should.equal(writers)
  end

  it 'should to_s keys when #ldelete' do

    writers = %w[ shonagon shikibu ]
    writers.each { |s| @db[s] = s }

    @db.ldelete(writers.collect { |w| w.to_sym })

    @db.size.should.equal(0)
  end

  it 'should to_s keys when #incr' do

    @db.incr(:genji_count, 1).should.equal(1)
    @db.incr(:genji_count, 1).should.equal(2)
  end

  it 'should to_s keys and values when #merge!' do

    @db.merge!(:genji => 1, :to_no_chujo => 2)

    @db['genji'].should.equal('1')
    @db['to_no_chujo'].should.equal('2')
  end
end

shared 'an abstract structure with a default value' do

  it 'should restitute the default value' do

    @db['known'].should.equal('Ulysse')
    @db['unknown'].should.equal('Nemo')
  end
end

shared 'an abstract structure with a default_proc' do

  it 'should restitute the value computed by the default_proc' do

    @db['known'].should.equal('Ulysse')
    @db['unknown'].should.equal('default:unknown')
  end
end

