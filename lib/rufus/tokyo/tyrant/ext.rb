module Rufus::Tokyo
  
  module Ext
    # Calls a lua embedded function
    # (http://tokyocabinet.sourceforge.net/tyrantdoc/#luaext)
    #
    # Options are :global_locking and :record_locking
    #
    # Returns the return value of the called function.
    #
    # Nil is returned in case of failure.
    #
    def ext (func_name, key='', value='', opts={})
      
      k = key.to_s
      v = value.to_s
      
      outlen_op(
        :tcrdbext,
        func_name.to_s,
        compute_ext_opts(opts),
        k, Rufus::Tokyo.blen(k),
        v, Rufus::Tokyo.blen(v))
    end
    
  end
  
end
