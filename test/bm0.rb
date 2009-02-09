
$:.unshift('lib')

require 'benchmark'
require 'rubygems'

N = 10_000

puts
puts "N is #{N}"

#
# Tokyo Cabinet ===============================================================
#

require 'rufus/tokyo/cabinet'

FileUtils.rm_f('tmp/test.tch')

table = Rufus::Tokyo::Cabinet.new('tmp/test.tch')
table.clear

2.times { puts }
puts 'TC'

Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all') do
    table.values
  end
  b.report('iterate all') do
    table.each { |k, v| }
  end
  b.report('find first') do
    table["key #{0}"]
  end
  b.report('delete first') do
    table.delete("key #{0}")
  end
end

table.close

#
# Tokyo Tyrant ================================================================
#

require 'rufus/tokyo/tyrant'

table = Rufus::Tokyo::Tyrant.new('127.0.0.1', 44001)
table.clear

2.times { puts }
puts 'TT'

Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all') do
    table.values
  end
  b.report('iterate all') do
    table.each { |k, v| }
  end
  b.report('find first') do
    table["key #{0}"]
  end
  b.report('delete first') do
    table.delete("key #{0}")
  end
end

table.close

puts


#
# Mon Feb  9 16:10:21 JST 2009
#
#
# N is 10000
#
# TC
#                           user     system      total        real
# inserting one         0.000000   0.000000   0.000000 (  0.000105)
# inserting N           0.060000   0.000000   0.060000 (  0.069892)
# finding all           0.120000   0.010000   0.130000 (  0.124895)
# iterate all           0.090000   0.000000   0.090000 (  0.093795)
# find first            0.000000   0.000000   0.000000 (  0.000018)
# delete first          0.000000   0.000000   0.000000 (  0.000053)
#
#
# TT
#                           user     system      total        real
# inserting one         0.000000   0.000000   0.000000 (  0.000262)
# inserting N           0.160000   0.200000   0.360000 (  1.105653)
# finding all           0.280000   0.410000   0.690000 (  2.089718)
# iterate all           0.280000   0.400000   0.680000 (  2.062686)
# find first            0.000000   0.000000   0.000000 (  0.000155)
# delete first          0.000000   0.000000   0.000000 (  0.000224)
#

