
%w{ lib test }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $: << path unless $:.include?(path)
end

require 'fileutils'


def self_ps
  ps = `ps -v #{$$}`.split("\n").last.split(' ')
  %w{
    pid stat time sl re pagein vsz rss lim tsiz pcpu pmem command
  }.inject({}) { |h, k|
    h[k.intern] = ps.shift; h
  }
end

def pmem (msg)
  p [ msg, "#{self_ps[:vsz].to_i / 1024}k" ]
end

pmem 'starting'

require 'rubygems'
require 'rufus/tokyo/util'

pmem 'required'

l = Rufus::Tokyo::List.new

100000.times { |i| l << i.to_s }

pmem 'stored'

#100000.times { |i| l.delete_at(0) }
#100000.times { |i| s = l.delete_at(0); Rufus::Tokyo::CabinetLib.tcfree(s) }
s = nil
100000.times { |i| s ||= l.delete_at(0); }
p s.class
p s.public_methods.sort

pmem 'cleared'

