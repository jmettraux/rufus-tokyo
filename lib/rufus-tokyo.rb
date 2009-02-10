#
# don't require rubygems if not necessary
#
unless defined?(FFI)
  begin
    require 'ffi'
  rescue LoadError
    retry if require 'rubygems'
  end
end

require 'rufus/tokyo'
