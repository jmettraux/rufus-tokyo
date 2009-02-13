
#
# Specifying rufus-tokyo
#
# Sun Feb  8 13:15:08 JST 2009
#

#
# bacon

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'rubygems'
require 'fileutils'

$:.unshift(File.expand_path('~/tmp/bacon/lib')) # my own bacon for a while

require 'bacon'

require 'rufus-tokyo'
include Rufus::Tokyo

puts

Bacon.summary_on_exit

