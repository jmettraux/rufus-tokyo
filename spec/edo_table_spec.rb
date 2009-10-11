
#
# Specifying rufus-tokyo
#
# Mon Feb 23 11:11:10 JST 2009
#

require File.join(File.dirname(__FILE__), 'spec_base')
require File.join(File.dirname(__FILE__), 'shared_table_spec')

begin
  require 'rufus/edo'
rescue LoadError
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe Rufus::Edo::Table do

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
  
  describe Rufus::Edo::Table do

    it 'should use open with a block will auto close the db correctly' do

      res = Rufus::Edo::Table.open('tmp/spec_source.tct') do |table|
        10.times { |i| table["key #{i}"] = {:val => i} }
        table.size.should.equal(10)
        :result
      end

      res.should.equal(:result)

      table = Rufus::Edo::Table.new('tmp/spec_source.tct')
      10.times do |i|
        table["key #{i}"].should.equal({"val" => i.to_s})
      end
      table.close

      FileUtils.rm('tmp/spec_source.tct')
    end


    it 'should use open without a block just like calling new correctly' do

      table = Rufus::Edo::Table.open('tmp/spec_source.tct')
      10.times { |i| table["key #{i}"] = {:val => i} }
      table.size.should.equal(10)
      table.close

      table = Rufus::Edo::Table.new('tmp/spec_source.tct')
      10.times do |i|
        table["key #{i}"].should.equal({"val" => i.to_s})
      end
      table.close

      FileUtils.rm('tmp/spec_source.tct')
    end
  end

  describe Rufus::Edo::Table do

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

    behaves_like 'table'
  end

  describe Rufus::Edo::Table do

    before do
      @t = Rufus::Edo::Table.new('tmp/table.tct')
      @t.clear
    end
    after do
      @t.close
    end

    behaves_like 'table with transactions'
  end

  # DONE

  describe 'Rufus::Edo::Table #keys' do

    before do
      @n = 50
      @t = Rufus::Edo::Table.new('tmp/test_new.tct')
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

    behaves_like 'table indexes'
  end

  describe 'Rufus::Edo::Table#lget' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'table lget'
  end

  describe 'Rufus::Edo::Table, like a Ruby Hash,' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'table like a hash'
  end

  describe 'queries on Rufus::Edo::Table' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'table query'

    #if TokyoCabinet::TDBQRY.public_instance_methods.collect { |e|
    #  e.to_s }.include?('setlimit')

    #  it 'can be limited and have an offset' do

    #    @t.query { |q|
    #      q.add 'lang', :includes, 'en'
    #      q.order_by 'name', :desc
    #      q.limit 2, 0
    #    }.collect { |e| e['name'] }.should.equal(%w{ jim jeff })
    #    @t.query { |q|
    #      q.add 'lang', :includes, 'en'
    #      q.order_by 'name', :desc
    #      q.limit 2, 2
    #    }.collect { |e| e['name'] }.should.equal(%w{ jake jack })
    #  end
    #end
  end

  describe 'Queries on Tokyo Tyrant tables (via Rufus::Edo)' do

    before do
      @t = Rufus::Edo::Table.new('tmp/test_new.tct')
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

  describe 'results from Rufus::Edo::Table queries' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'table query results'
  end

  describe Rufus::Edo::Table do

    before do
      @t = Rufus::Edo::Table.new('tmp/table.tct')
      @t.clear
    end
    after do
      @t.close
    end

    behaves_like 'a table structure flattening keys and values'
  end

  describe 'Rufus::Edo::Table\'s queries' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'a table structure to_s-ing query stuff'
  end

  describe 'Rufus::Edo::Table and metasearch' do

    before do
      @t = prepare_table_with_data
    end
    after do
      @t.close
    end

    behaves_like 'table query metasearch'
  end
end

