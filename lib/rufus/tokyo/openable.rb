module Rufus::Tokyo
  #
  # A mixin for classes with new() that need a matching IO-like open().
  #
  module Openable
    #
    # Same args as new(), but can take a block form that will
    # close the db when done. Similar to File.open(). (via Zev and JEG2)
    #
    def open(*args)
      db = new(*args)
      if block_given?
        begin
          yield db
        ensure 
          db.close
        end
      else
        db
      end
    end
  end
end
