
require 'rubygems'
require 'faker'
require 'benchmark'
require 'rufus/tokyo'

N = 100_000

NAME = Faker::Name.name

DATA = (0..N-1).collect { |i|
  #{ 'name' => Faker::Name.name, 'sex' => 'male' }
  { 'name' => NAME * 100, 'sex' => 'male' }
}

t0 = Rufus::Tokyo::Table.new('toto0.tdb')
t1 = Rufus::Tokyo::Table.new('toto1.tdb', :opts => 'ld')
t2 = Rufus::Tokyo::Table.new('toto2.tdb', :opts => 'lb')
#t3 = Rufus::Tokyo::Table.new('toto3.tdb', :opts => 'lt')

t0.clear
t1.clear
t2.clear
#t3.clear

Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|
  b.report('no compression') do
    DATA.each_with_index { |row, i| t0["pk#{i}"] = row }
  end
  b.report('deflate') do
    DATA.each_with_index { |row, i| t1["pk#{i}"] = row }
  end
  b.report('bzip2') do
    DATA.each_with_index { |row, i| t2["pk#{i}"] = row }
  end
  #b.report('tcbs') do
  #  DATA.each_with_index { |row, i| t3["pk#{i}"] = row }
  #end
end

t0.close
t1.close
t2.close
#t3.close

puts

puts 'no compression  : ' + `ls -l toto0.tdb | awk '{ print $5 }'`
puts 'deflate         : ' + `ls -l toto1.tdb | awk '{ print $5 }'`
puts 'bzip2           : ' + `ls -l toto2.tdb | awk '{ print $5 }'`
#puts 'tcbs            : ' + `ls -l toto3.tdb | awk '{ print $5 }'`

puts

