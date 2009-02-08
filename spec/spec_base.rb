
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
require 'bacon'

Bacon.summary_on_exit

