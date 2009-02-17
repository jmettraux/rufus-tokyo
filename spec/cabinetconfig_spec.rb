
#
# Specifying rufus-tokyo
#
# Sun Feb  8 16:01:51 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo'


describe 'Rufus::Tokyo::CabinetConfig' do

  before do
    @c = Object.new
    @c.extend(Rufus::Tokyo::CabinetConfig)
    class << @c
      public :determine_open_mode, :determine_conf
    end
  end

  it 'should open with mode=cw by default' do

    @c.determine_open_mode({ :mode => ''}).should.equal(6)
    @c.determine_open_mode({ 'mode' => '' }).should.equal(6)
  end

  it 'should determine mode flags correctly' do

    @c.determine_open_mode( :mode => 'e').should.equal(16)
    @c.determine_open_mode( :mode => 're').should.equal(17)
    @c.determine_open_mode( :mode => 'ce').should.equal(20)
  end

  it 'should separate path from params' do

    @c.determine_conf(
      'nada.tdb#mode=r', {}, '.tdb')[:path].should.equal('nada.tdb')
  end

  it 'should not accept suffixes else than .tdb' do

    lambda {
      @c.determine_conf('nada.tcx', {}, '.tdb').should.be.nil
    }.should.raise(RuntimeError)

    lambda {
      @c.determine_conf('nada.tcx#mode=r', {}, '.tdb').should.be.nil
    }.should.raise(RuntimeError)
  end

  it 'should grant write/create by default' do

    @c.determine_conf('nada.tdb', {}, '.tdb')[:mode].should.equal(6)
  end

  it 'should respect :mutex' do

    @c.determine_conf(
      'nada.tdb#mutex=true', {}, '.tdb')[:mutex].should.equal(true)
    @c.determine_conf(
      'nada.tdb', { :mutex => true}, '.tdb')[:mutex].should.equal(true)
  end

end

