
#
# specifying rufus-tokyo
#
# Sun Feb  8 13:12:54 JST 2009
#

Dir[ "#{File.dirname(__FILE__)}/*_spec.rb" ].each do |path|
  load(path) unless File.basename(path).match(/^shared\_/)
end

