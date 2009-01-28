
dirpath = File.dirname(__FILE__)

require dirpath + '/test_base'

require dirpath + '/cabinet/test'
require dirpath + '/dystopia/test'

#cab_tests = Dir.new(dirpath).entries.collect { |e| "#{dir
#tests = (cab_tests + dys_tests).select { |e| e.match(/\_test.rb$/) }.sort
#
#(cab_tests + dys_tests).each { |path| require "#{dirpath}/#{path}" }

