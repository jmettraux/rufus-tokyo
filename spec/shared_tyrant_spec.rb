
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

