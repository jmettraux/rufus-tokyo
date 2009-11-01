require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'

FileUtils.mkdir('tmp') rescue nil


describe 'Rufus::Tokyo::Cabinet .tcf' do

  before do
    @db = Rufus::Tokyo::Cabinet.new('tmp/cabinet_fixed_spec.tcf', :width => 4)
    @db.clear
  end
  after do
    @db.close
  end

  it 'should support keys' do
    @db[1] = "one"
    @db[2] = "two"
    @db[3] = "three"
    @db[7] = "seven"
    @db.keys.should.equal(%w[1 2 3 7])
  end

  it 'should accept a width at creation' do

    @db[1] = "one"
    @db[2] = "two"
    @db[3] = "three"
    @db.to_a.should.equal([%w[1 one], %w[2 two], %w[3 thre]])
  end
end
