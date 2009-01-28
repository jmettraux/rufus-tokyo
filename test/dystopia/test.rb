
dp = File.dirname(__FILE__)

Dir.new(dp).entries.select { |e|
  e.match(/\_test.rb$/)
}.sort.each { |e|
  require "#{dp}/#{e}"
}

