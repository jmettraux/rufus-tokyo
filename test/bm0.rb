
#
# a bit of benchmarking
#
# some gists of runs :
#
# http://gist.github.com/60709
#

$:.unshift('lib')

require 'benchmark'

require 'date'
require 'fileutils'

require 'rubygems'

N = 10_000

puts
puts Time.now.to_s
puts "N is #{N}"
puts "ruby is #{RUBY_VERSION}"

# ==============================================================================
# hashes
# ==============================================================================

#
# Tokyo Cabinet ===============================================================
#

require 'rufus/tokyo'

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

table = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
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


# ==============================================================================
# tables
# ==============================================================================

require 'faker'

DATA = (0..N - 1).collect { |i|
  {
    'name' => Faker::Name.name,
    'sex' => (i % 2) ? 'male' : 'female',
    'birthday' => DateTime.new(1972, 10, 14),
    'divisions' => (i % 2) ? 'brd' : 'dev'
  }
}

DATA1 = DATA.collect { |e|
  h = e.dup
  h['birthday'] = h['birthday'].to_s
  h
}
  # Tokyo Cabinet tables only do strings


#
# Tokyo Cabinet table =========================================================
#

FileUtils.rm_f('tmp/test.tdb')

table = Rufus::Tokyo::Table.new('tmp/test.tdb')
table.clear

2.times { puts }
puts 'TC table'

Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table[i.to_s] = e }
  end
  b.report('finding all') do
    table.query { |q| }
  end
  b.report('find last') do
    table[DATA.size.to_s]
  end
  b.report('delete last') do
    table.delete(DATA.size.to_s)
  end
  b.report('find Alphonse') do
    table.query { |q| q.add('name', :equals, DATA1[0]['name']) }
  end
end


#
# Tokyo Tyrant table ==========================================================
#

table = Rufus::Tokyo::TyrantTable.new('localhost', 45001)
table.clear

2.times { puts }
puts 'TT table'

Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table[i.to_s] = e }
  end
  b.report('finding all') do
    table.query { |q| }
  end
  b.report('find last') do
    table[DATA.size.to_s]
  end
  b.report('delete last') do
    table.delete(DATA.size.to_s)
  end
  b.report('find Alphonse') do
    table.query { |q| q.add('name', :equals, DATA1[0]['name']) }
  end
end

puts

