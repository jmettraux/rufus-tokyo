
dirpath = File.dirname(__FILE__)

require dirpath + '/test_base'


tests = Dir.new(dirpath).entries.select { |e| e.match(/\_test.rb$/) }.sort

tests.each { |path| load "#{dirpath}/#{path}" }

