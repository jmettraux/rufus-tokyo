
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


# Are the 'native'/'author' ruby bindings present ?

puts

begin
  require 'tokyocabinet'
rescue LoadError
  puts "Tokyo Cabinet 'native' ruby bindings not present"
end

begin
  require 'tokyotyrant'
rescue LoadError
  puts "Tokyo Tyrant 'native' ruby bindings not present"
end

begin
  require 'memcache'
rescue LoadError
  puts "\ngem memcache-client not present"
end

# moving on...

N = 10_000

puts
puts Time.now.to_s
puts "N is #{N}"
puts "ruby is #{RUBY_VERSION}"

# ==============================================================================
# bench methods
# ==============================================================================

#
# note : pre db.clear and post db.close are included.
#
def rufus_cabinet_bench (bench_title, db)

  db.clear

  2.times { puts }
  puts bench_title

  Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|

    b.report('inserting one') do
      db['a'] = 'A'
    end
    b.report('inserting N') do
      N.times { |i| db["key #{i}"] = "value #{i}" }
    end
    b.report('finding all keys') do
      db.keys
    end

    unless db.class.name.match(/^Rufus::Edo::/)
      b.report('finding all keys (native)') do
        db.keys(:native => true).free
      end
    end

    b.report('finding all keys (pref)') do
      db.keys(:prefix => 'key ')
    end
    b.report('finding all keys (r pref)') do
      db.keys.select { |k| k[0, 4] == 'key ' }
    end
    b.report('finding all') do
      db.values
    end
    b.report('iterate all') do
      db.each { |k, v| }
    end
    b.report('find first') do
      db["key #{0}"]
    end
    b.report('delete first') do
      db.delete("key #{0}")
    end

    txt = 'delete_keys_with_prefix "1"'
    txt += ' (M)' if db.class.name == 'Rufus::Edo::Cabinet'
    b.report(txt) do
      db.delete_keys_with_prefix('key 1')
    end

    b.report('del keys with prefix "2" (m)') do
      ks = db.keys(:prefix => 'key 2')
      ks.each { |k| db.delete(k) }
    end
  end

  db.close
end

# = table ==

puts "\npreparing fake data for table tests..."

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


# = memcache ===

#
# tiny test for memcache_client gem
#
# note : space is an illegal char in keys here !
#
def limited_bench (bench_title, db)

  2.times { puts }
  puts bench_title

  Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|

    b.report('inserting one') do
      db['a'] = 'A'
    end
    b.report('inserting N') do
      N.times { |i| db["key#{i}"] = "value #{i}" }
    end
    b.report('find first') do
      db["key#{0}"]
    end
    b.report('delete first') do
      db.delete("key#{0}")
    end
  end
end


#
# note : pre db.clear and post db.close are included.
#
def rufus_table_bench (bench_title, db)

  2.times { puts }
  puts bench_title

  Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|

    db.clear

    db.clear
    db.set_index('name', :lexical)

    b.report('inserting data (index set)') do
      DATA1.each_with_index { |e, i| db["key #{i.to_s}"] = e }
    end

    db.clear
    db.set_index('name', :remove)

    b.report('inserting data (no index)') do
      DATA1.each_with_index { |e, i| db["key #{i.to_s}"] = e }
    end

    b.report('finding all keys') do
      db.keys
    end
    b.report('finding all keys (pref)') do
      db.keys(:prefix => 'key ')
    end
    b.report('finding all keys (r pref)') do
      db.keys.select { |k| k[0, 4] == 'key ' }
    end
    b.report('finding all') do
      db.query { |q| }
    end
    b.report('find last') do
      db["key #{DATA.size.to_s}"]
    end
    b.report('delete last') do
      db.delete("key #{DATA.size.to_s}")
    end
    b.report('find Alphonse') do
      db.query { |q| q.add('name', :equals, DATA1[0]['name']) }
    end

    b.report("setting index (#{DATA.size} rows)") do
      db.set_index('name', :lexical)
    end

    b.report('find Alphonse (index set)') do
      db.query { |q| q.add('name', :equals, DATA1[0]['name']) }
    end

    b.report('delete_keys_with_prefix "1"') do
      db.delete_keys_with_prefix('key 1')
    end
    #b.report('del keys with prefix "2" (m)') do
    #  ks = db.keys(:prefix => 'key 2')
    #  ks.each { |k| db.delete(k) }
    #end
  end

  db.close
end

# ==============================================================================
# hashes
# ==============================================================================

#
# Tokyo Cabinet ===============================================================
#

require 'rufus/tokyo'

FileUtils.rm_f('tmp/test.tch')

rufus_cabinet_bench('TC', Rufus::Tokyo::Cabinet.new('tmp/test.tch'))

#
# 'native' ruby bindings
#

FileUtils.rm_f('tmp/test.tch')

if defined?(TokyoCabinet)

  require 'rufus/edo'

  rufus_cabinet_bench('Edo TC', Rufus::Edo::Cabinet.new('tmp/test.tch'))
end


#
# Tokyo Tyrant ================================================================
#

require 'rufus/tokyo/tyrant'

rufus_cabinet_bench('TT', Rufus::Tokyo::Tyrant.new('127.0.0.1', 45000))


#
# 'native' Tokyo Tyrant ========================================================
#

if defined?(TokyoTyrant)

  require 'rufus/edo/ntyrant'

  rufus_cabinet_bench('net TT', Rufus::Edo::NetTyrant.new('127.0.0.1', 45000))
end


if defined?(MemCache)

  db = MemCache.new(
    :compression => false,
    :readonly => false,
    :debug => false)
  db.servers = [ '127.0.0.1:45000' ]

  limited_bench('TT over memcache-client', db)

  db = MemCache.new(
    :compression => true,
    :readonly => false,
    :debug => false)
  db.servers = [ '127.0.0.1:45000' ]

  limited_bench('TT over memcache-client (:compression => true)', db)
end


# ==============================================================================
# tables
# ==============================================================================

#
# Tokyo Cabinet table =========================================================
#

FileUtils.rm_f('tmp/test.tct')

rufus_table_bench('TC table', Rufus::Tokyo::Table.new('tmp/test.tct'))


#
# 'native' Tokyo Cabinet table =================================================
#

FileUtils.rm_f('tmp/test.tct')


if defined?(TokyoCabinet)

  require 'rufus/edo'

  rufus_table_bench('Edo TC table', Rufus::Edo::Table.new('tmp/test.tct'))
end

#
# Tokyo Tyrant table ===========================================================
#

rufus_table_bench(
  'TT table', Rufus::Tokyo::TyrantTable.new('localhost', 45001))


#
# 'author' Tokyo Tyrant table ==================================================
#

if defined?(TokyoTyrant)

  rufus_table_bench(
    "net TT table", Rufus::Edo::NetTyrantTable.new('127.0.0.1', 45001))
end

puts

