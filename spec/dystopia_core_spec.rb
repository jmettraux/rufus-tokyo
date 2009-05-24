
#
# Specifying rufus-tokyo
#
require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo/dystopia'

FileUtils.mkdir('tmp') rescue nil

describe 'Rufus::Tokyo::Dystopia::Core' do
  before do
    @db = Rufus::Tokyo::Dystopia::Core.new( 'tmp/dystopia')
    @db.clear
  end

  after do
    @db.close
    FileUtils.rm_rf( 'tmp/dystopia' )
  end

  it 'creates a new directory when started' do
    File.directory?( 'tmp/dystopia' ).should.equal( true )
  end

  it 'knows its own full path' do
    p = @db.path
    File.directory?( p ).should.equal( true )
    p.should.equal( File.expand_path("tmp/dystopia" ) )
  end

  it "knows its record count" do
    @db.count.should.equal( 0 )
    @db.store( 1, "John Adams" )
    @db.count.should.equal( 1 )
  end

  it "knows how much drive space it takes up in bytes" do
    b = @db.fsize
    @db.store( 1, "John Adams" )
    @db.store( 3, "George Washington" )
    @db.fsize.should > b
  end

  it "can add records" do
    @db.count.should.equal(0)
    @db.store( 1, "John Adams" )
    @db.store( 3, "George Washington" )
    @db.count.should.equal( 2 )
  end

  it "can remove records" do
    @db.count.should.equal(0)
    @db.store( 1, "John Adams" )
    @db.store( 3, "George Washington" )
    @db.count.should.equal( 2 )
    @db.delete( 3 )
    @db.count.should.equal( 1 )
  end

  it "retrieves the whole record of items it has stored" do
    @db.store( 1, "John Adams" )
    @db.store( 3, "George Washington" )

    @db.fetch( 3 ).should == "George Washington"
    @db.fetch( 1 ).should == "John Adams"

  end

  it "returns nil when the fetched document does not exist" do
    @db.store( 1, "John Adams" )
    @db.count.should == 1
    @db.fetch( 3 ).should == nil
  end

  it "searches for text in the database" do
    [ 'John Adams', 'George Washington', 'Thomas Jefferson' ].each_with_index do |e, idx|
      @db.store( idx + 1, e )
    end
    r = @db.search( "on" )
    r.size.should == 2
    r.sort.should == [ 2, 3 ]

    r = @db.search( "John")
    r.size.should == 1
    r.should == [ 1 ]
  end
end
