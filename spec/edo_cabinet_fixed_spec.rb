require File.dirname(__FILE__) + '/spec_base'

begin
  require 'rufus/edo'
rescue LoadError
  puts "'TokyoCabinet' ruby bindings not available on this ruby platform"
end

if defined?(TokyoCabinet)

  FileUtils.mkdir('tmp') rescue nil


  describe 'Rufus::Edo::Cabinet .tcf' do
    
    before do
      @db = Rufus::Edo::Cabinet.new( 'tmp/edo_cabinet_fixed_spec.tcf',
                                     :width => 4 )
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
end

