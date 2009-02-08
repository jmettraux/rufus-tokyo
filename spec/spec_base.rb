
#
# Specifying rufus-tokyo
#
# Sun Feb  8 13:15:08 JST 2009
#

%w{ lib }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $: << path unless $:.include?(path)
end

require 'rubygems'

$:.unshift('~/tmp/bacon/lib') # my own bacon for a while
require 'bacon'

puts

Bacon.summary_on_exit

