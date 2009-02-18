
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

N = 100_000

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

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (native)') do
    table.keys(:native => true).free
  end
  b.report('finding all keys (pref)') do
    table.keys(:prefix => 'key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
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
# Ruby C Binding
#

begin

require 'tokyocabinet'
$source_tc = true

FileUtils.rm_f('tmp/test.tch')
table = TokyoCabinet::HDB.new
if !table.open('tmp/test.tch', TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
  ecode = table.ecode
  puts "open error: #{hdb.errmsg(ecode)}"
  exit 1
end

table.clear

2.times { puts }
puts 'TC C binding'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all keys') do
    table.keys
  end

  b.report('finding all keys (pref)') do
    table.fwmkeys('key ')
  end

  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
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

rescue LoadError
  puts "C binding not installed"
end

#
# Tokyo Tyrant ================================================================
#

require 'rufus/tokyo/tyrant'


table = Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000)
table.clear

2.times { puts }
puts 'TT'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.keys(:prefix => 'key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
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
# Souce Tokyo Tyrant ================================================================
#
begin

require 'tokyotyrant'
$source_tt = true

table = TokyoTyrant::RDB.new
table.open('127.0.0.1', 45000)
table.clear

2.times { puts }
puts 'Source TT'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting one') do
    table['a'] = 'A'
  end
  b.report('inserting N') do
    N.times { |i| table["key #{i}"] = "value #{i}" }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.fwmkeys('key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
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

rescue LoadError
  puts "Cannot load source verions of TokyoTyrant"
end

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

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table["key #{i.to_s}"] = e }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.keys(:prefix => 'key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
  end
  b.report('finding all') do
    table.query { |q| }
  end
  b.report('find last') do
    table["key #{DATA.size.to_s}"]
  end
  b.report('delete last') do
    table.delete("key #{DATA.size.to_s}")
  end
  b.report('find Alphonse') do
    table.query { |q| q.add('name', :equals, DATA1[0]['name']) }
  end
end


if $source_tc

#
# Source Tokyo Cabinet table =========================================================
#

FileUtils.rm_f('tmp/test.tdb')


table = TokyoCabinet::TDB.new
if !table.open('tmp/test.tct', TokyoCabinet::TDB::OWRITER | TokyoCabinet::TDB::OCREAT)
  ecode = table.ecode
  puts "open error: #{hdb.errmsg(ecode)}"
  exit 1
end

table.clear

2.times { puts }
puts 'Source TC table'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table["key #{i.to_s}"] = e }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.fwmkeys('key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
  end
  b.report('finding all') do
    qry = TokyoCabinet::TDBQRY::new(table)
    qry.search
  end
  b.report('find last') do
    table["key #{DATA.size.to_s}"]
  end
  b.report('delete last') do
    table.delete("key #{DATA.size.to_s}")
  end
  b.report('find Alphonse') do
    qry = TokyoCabinet::TDBQRY::new(table)
    qry.addcond("name", TokyoCabinet::TDBQRY::QCSTREQ, DATA1[0]['name'])
    qry.search
  end
end
end


#
# Tokyo Tyrant table ==========================================================
#

table = Rufus::Tokyo::TyrantTable.new('localhost', 45001)
table.clear

2.times { puts }
puts 'TT table'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table["key #{i.to_s}"] = e }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.keys(:prefix => 'key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
  end
  b.report('finding all') do
    table.query { |q| }
  end
  b.report('find last') do
    table["key #{DATA.size.to_s}"]
  end
  b.report('delete last') do
    table.delete("key #{DATA.size.to_s}")
  end
  b.report('find Alphonse') do
    table.query { |q| q.add('name', :equals, DATA1[0]['name']) }
  end
end

if !$source_tt
  puts
  exit 0
end

#
# Source Tokyo Tyrant table ==========================================================
#

table = TokyoTyrant::RDBTBL.new
table.open('localhost', 45001)
table.clear

2.times { puts }
puts 'Source TT table'

Benchmark.benchmark(' ' * 30 + Benchmark::Tms::CAPTION, 30) do |b|

  b.report('inserting data') do
    DATA1.each_with_index { |e, i| table["key #{i.to_s}"] = e }
  end
  b.report('finding all keys') do
    table.keys
  end
  b.report('finding all keys (pref)') do
    table.fwmkeys('key ')
  end
  b.report('finding all keys (r pref)') do
    table.keys.select { |k| k[0, 4] == 'key ' }
  end
  b.report('finding all') do
    qry = TokyoTyrant::RDBQRY::new(table)
    qry.search
  end
  b.report('find last') do
    table["key #{DATA.size.to_s}"]
  end
  b.report('delete last') do
    table.delete("key #{DATA.size.to_s}")
  end
  b.report('find Alphonse') do
    qry = TokyoTyrant::RDBQRY::new(table)
    qry.addcond("name", TokyoTyrant::RDBQRY::QCSTREQ, DATA1[0]['name'])
    qry.search
  end
end


puts

