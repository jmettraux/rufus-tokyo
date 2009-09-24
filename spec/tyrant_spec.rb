
#
# Specifying rufus-tokyo
#
# Sun Feb  8 13:13:41 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'
require File.dirname(__FILE__) + '/shared_abstract_spec'
require File.join(File.dirname(__FILE__), 'shared_tyrant_spec')

require 'rufus/tokyo/tyrant'


describe 'a missing Rufus::Tokyo::Tyrant' do

  it 'should raise an error' do

    lambda {
      Rufus::Tokyo::Tyrant.new('127.0.0.1', 1)
    }.should.raise(Rufus::Tokyo::TokyoError).message.should.equal(
      "couldn't connect to tyrant at 127.0.0.1:1")
  end
end

describe Rufus::Tokyo::Tyrant do

  it 'should open and close' do

    should.not.raise {
      t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
      t.close
    }
  end

  it 'should refuse to connect to a TyrantTable' do

    lambda {
      t = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45001)
    }.should.raise(ArgumentError)
  end
end

describe Rufus::Tokyo::Tyrant do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure'
  behaves_like 'a Tyrant structure (no transactions)'

  it 'should respond to stat' do

    stat = @db.stat
    stat['type'].should.equal('hash')
  end
end

describe Rufus::Tokyo::Tyrant do

  before do

    @n = 50
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
    @n.times { |i| @db["person#{i}"] = 'whoever' }
    @n.times { |i| @db["animal#{i}"] = 'whichever' }
    @db["toto#{0.chr}5"] = 'toto'
  end

  after do

    @db.close
  end

  behaves_like 'abstract structure #keys'
end

describe Rufus::Tokyo::Tyrant do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
    3.times { |i| @db[i.to_s] = "val#{i}" }
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #lget/lput/ldelete'
end

describe Rufus::Tokyo::Tyrant do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #add{int|double}'
end

describe Rufus::Tokyo::Tyrant do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'abstract structure #putkeep'
  behaves_like 'abstract structure #putcat'
end

describe 'Rufus::Tokyo::Tyrant (lua extensions)' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'tyrant with embedded lua'
end

describe Rufus::Tokyo::Tyrant do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
    @db.clear
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure flattening keys and values'
end

describe 'Rufus::Tokyo::Tyrant with a default value' do

  before do
    @db = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000, :default => 'Nemo')
    @db.clear
    @db['known'] = 'Ulysse'
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure with a default value'
end

describe 'Rufus::Tokyo::Tyrant with a default_proc' do

  before do
    @db = Rufus::Tokyo::Tyrant.new(
      '127.0.0.1',
      45000,
      :default_proc => lambda { |db, k| "default:#{k}" })
    @db.clear
    @db['known'] = 'Ulysse'
  end
  after do
    @db.close
  end

  behaves_like 'an abstract structure with a default_proc'
end
