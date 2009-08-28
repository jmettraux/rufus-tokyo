
#
# Specifying rufus-tokyo
#
# Fri Aug 28 08:58:37 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo'
rescue LoadError
  puts "'TokyoCabinet' ruby bindings not available on this ruby platform"
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe 'Rufus::Edo::Cabinet .tcb' do

    before do
      @db = Rufus::Edo::Cabinet.new('tmp/edo_cabinet_btree_spec.tcb')
      @db.clear
    end
    after do
      @db.close
    end

    it 'should accept duplicate values' do

      @db.putdup('a', 'a0')
      @db.putdup('a', 'a1')

      @db.getdup('a').should.equal([ 'a0', 'a1' ])
    end
  end

  describe 'Rufus::Edo::Cabinet .tcb methods' do

    it 'should fail on other structures' do

      @db = Rufus::Edo::Cabinet.new('tmp/cabinet_btree_spec.tch')

      lambda { @db.putdup('a', 'a0') }.should.raise(NoMethodError)
    end
  end
end

