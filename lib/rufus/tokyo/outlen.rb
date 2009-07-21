module Rufus::Tokyo
  module Outlen
    
    # A wrapper for library returning a string (binary data potentially)
    #
    def outlen_op (method, *args)
      
      args.unshift(@db)
      
      outlen = FFI::MemoryPointer.new(:int)
      args << outlen
      
      out = lib.send(method, *args)
      
      return nil if out.address == 0
      return out.get_bytes(0, outlen.get_int(0))
    ensure
      outlen.free
    end
    
  end
end

