
def self_ps
  ps = `ps -v #{$$}`.split("\n").last.split(' ')
  %w{
    pid stat time sl re pagein vsz rss lim tsiz pcpu pmem command
  }.inject({}) { |h, k|
    h[k.intern] = ps.shift; h
  }
end

p self_ps

