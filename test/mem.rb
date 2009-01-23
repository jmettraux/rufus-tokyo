
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
require 'rufus/tokyo'

FileUtils.rm('test_mem.tch')

db = Rufus::Tokyo::Cabinet.new('test_mem.tch')

pmem 'wired to db'

500_000.times { |i| db[i.to_s] = "value#{i}" }

pmem 'loaded 500_000 records'

db.each { |k, v| k }

pmem 'iterated 500_000 records'

a = db.collect { |k, v| k + v }

pmem 'collected 500_000 records'

db.close

pmem 'closed db'

