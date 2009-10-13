
#
# Specifying rufus-tokyo
#
# Thu Sep 24 10:59:39 JST 2009
#

shared 'a Tyrant structure (no transactions)' do

  it 'should raise NoMethodError on transactions' do

    ex = nil

    begin
      (@db || @t).transaction {}
    rescue Exception => e
      ex = e
    end

    ex.class.should.equal(NoMethodError)
    ex.message.should.match(/ support /)
  end
end

shared 'a Tyrant structure (copy method)' do

  it 'should accept #copy calls' do

    SOURCE = 'tmp/tyrant.tch'

    TARGET = File.expand_path(
      File.join(File.dirname(__FILE__), '../tmp/tyrant_copy.tch'))

    @db.copy(TARGET)

    File.exist?(TARGET).should.be.true
    File.stat(TARGET).size.should.equal(File.stat(SOURCE).size)

    FileUtils.rm(TARGET)
  end
end

