
#
# Specifying rufus-tokyo
#
# Sun Feb  8 15:02:08 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'


describe 'a Tokyo Cabinet hash' do

  before do
    FileUtils.mkdir('tmp') rescue nil
    @db = Cabinet.new('tmp/cabinet_spec.tch')
    @db.clear
  end

  after do
    @db.close
  end

  it 'should create its underlying file' do
    File.exist?('tmp/cabinet_spec.tch').should.equal(true)
  end

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

  it 'should reply to #keys and #values' do
    keys = %w{ alpha bravo charly delta echo foxtrott }
    keys.each_with_index { |k, i| @db[k] = i.to_s }
    @db.keys.should.equal(keys)
    @db.values.should.equal(%w{ 0 1 2 3 4 5 })
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

describe 'a Tokyo Cabinet hash' do

  before do
    FileUtils.mkdir('tmp') rescue nil
  end

  it 'should accept a default value' do
    cab = Cabinet.new(
      'tmp/cabinet_spec_default.tch', :default => '@?!')
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
  end

  it 'should accept a default value (later)' do
    cab = Cabinet.new('tmp/cabinet_spec_default.tch')
    cab.default = '@?!'
    cab['a'] = 'A'
    cab.size.should.equal(1)
    cab['b'].should.equal('@?!')
  end
end

describe 'a Tokyo Cabinet hash' do

  before do
    FileUtils.mkdir('tmp') rescue nil
  end

  it 'should copy correctly' do

    cab = Cabinet.new('tmp/spec_source.tch')
    5000.times { |i| cab["key #{i}"] = "val #{i}" }
    cab.size.should.equal(5000)
    cab.copy('tmp/spec_target.tch')
    cab.close

    cab = Cabinet.new('tmp/spec_target.tch')
    cab.size.should.equal(5000)
    cab['key 4999'].should.equal('val 4999')
    cab.close

    FileUtils.rm('tmp/spec_source.tch')
    FileUtils.rm('tmp/spec_target.tch')
  end

  it 'should copy compactly' do

    cab = Cabinet.new('tmp/spec_source.tch')
    100.times { |i| cab["key #{i}"] = "val #{i}" }
    50.times { |i| cab.delete("key #{i}") }
    cab.size.should.equal(50)
    cab.compact_copy('tmp/spec_target.tch')
    cab.close

    cab = Cabinet.new('tmp/spec_target.tch')
    cab.size.should.equal(50)
    cab['key 99'].should.equal('val 99')
    cab.close

    fs0 = File.size('tmp/spec_source.tch')
    fs1 = File.size('tmp/spec_target.tch')
    (fs0 > fs1).should.equal(true)

    FileUtils.rm('tmp/spec_source.tch')
    FileUtils.rm('tmp/spec_target.tch')
  end
end

