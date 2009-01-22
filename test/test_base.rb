
%w{ lib test }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $: << path unless $:.include?(path)
end

