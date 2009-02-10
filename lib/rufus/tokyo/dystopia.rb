class DystopianError < RuntimeError
  def new (error_code)
    super("tokyo dystopia error #{error_code}")
  end
end

require File.dirname(__FILE__)+'/dystopia/lib'
require File.dirname(__FILE__)+'/dystopia/words'
