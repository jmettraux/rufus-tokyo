#!/usr/bin/env ruby -wKU

require "rubygems"
require "ffi"

# map the C interface
module Lib
 extend FFI::Library
 ffi_lib(
   *Array(
     ENV.fetch(
       "TOKYO_CABINET_LIB",
       Dir["/{opt,usr}/{,local/}lib{,64}/libtokyocabinet.{dylib,so*}"]
     )
   )
 )

 attach_function :tcfree, [ :pointer ], :void

 attach_function :tchdbnew,   [ ],                                  :pointer
 attach_function :tchdbopen,  [:pointer, :string, :int],            :bool
 attach_function :tchdbput,   [:pointer, :pointer, :int, :pointer,
                               :int],                               :bool
 attach_function :tchdbget,   [:pointer, :pointer, :int, :pointer], :pointer
 attach_function :tchdbclose, [:pointer],                           :bool
end

# translate the interface to Ruby
class TokyoCabinet
 def self.open(*args)
   db = new(*args)
   yield db
 ensure
   db.close if db
 end

 def initialize(path)
   @db = Lib.tchdbnew
   Lib.tchdbopen(@db, path, (1 << 1) | (1 << 2))  # write create mode
 end

 def []=(key, value)
   k, v = key.to_s, value.to_s
   Lib.tchdbput(@db, k, k.size, v, v.size)
 end

 def [](key)
   k     = key.to_s
   size  = FFI::MemoryPointer.new(:int)
   value = Lib.tchdbget(@db, k, k.size, size)
   value.address.zero? ? nil : value.get_bytes(0, size.get_int(0))
 ensure
   size.free if size
   # FIXME:  How do I free value here?
   Lib.tcfree(value)
 end

 def close
   Lib.tchdbclose(@db)
 end
end

# show the problem
def show_memory
 3.times { GC.start }  # try to clean up
 mem = `ps -o rss -p #{Process.pid}`[/\d+/]
 puts "Current memory:  #{mem}"
end

TokyoCabinet.open("leak.tch") do |db|
 db[:some_key] = "X" * 1024
 10.times do
   5000.times do
     db[:some_key]  # reading causes the memory leak
   end
   show_memory
 end
end

